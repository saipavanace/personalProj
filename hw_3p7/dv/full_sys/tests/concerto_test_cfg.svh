////////////////////////////////////////////////////////////
//                                                        //
//Description: external tesks for ncore boot              //
//                                                        //
//                                                        //
//File     : concerto_test_cfg.sv                         //
//Author   : Cyrille LUDWIG                               //
////////////////////////////////////////////////////////////

<%
var all_chiaius_strname = obj.AiuInfo.filter(e => e.fnNativeInterface.match("CHI")).map(item => `"${item.strRtlNamePrefix}"`);
var all_axi4_without_cache = obj.AiuInfo.filter(e => (e.fnNativeInterface.match("AXI4") && !e.useCache)).map(item => `"${item.strRtlNamePrefix}"`); // !! don't have MPU without cache
var all_diis_strname = obj.DiiInfo.map(item => `"${item.strRtlNamePrefix}"`);
var all_dmis_strname = obj.DmiInfo.map(item => `"${item.strRtlNamePrefix}"`);
var all_ioaius_strname = obj.AiuInfo.filter(e => !e.fnNativeInterface.match("CHI")).map(item => 
                                       {
                                        var array = [];   
                                        if (Array.isArray(item.rpn)) {  //case multiple port use rpn array to add mpu0_0 , mpu0_1 .. <name>_<index>
                                           item.rpn.forEach((element,index) => array.push(`"${item.strRtlNamePrefix}_${index}"`));
                                        } else {
                                          array.push(`"${item.strRtlNamePrefix}"`);
                                        }
                                        return array.join(','); 
                                       }
                                       );
///!!! wait core index info in the CSR cf CONC-12053
// in case of sysco only core0 must process the sysco process
var all_ioaius_sysco_strname = obj.AiuInfo.filter(e => !e.fnNativeInterface.match("CHI")).map(item => 
                                       {
                                        if (Array.isArray(item.rpn)) {  //case multiple port use rpn is an array => add "_0"
                                           return `"${item.strRtlNamePrefix}_0"`;
                                        } else {
                                           return `"${item.strRtlNamePrefix}"`;
                                        }
                                       }
                                       );
var aiu_offset = []; //[0,4,5,6..]  aiu0(mpu 4 ports)= table[0]...[3]  aiu1=table[4] aiu2=table[5]
var aiu_NumCores = [];
var aiu_NumPorts =0;
for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { 
   if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       aiu_offset[pidx]      = aiu_NumPorts;
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].nNativeInterfacePorts;
       aiu_NumPorts          += obj.AiuInfo[pidx].nNativeInterfacePorts;
   } else {
       aiu_offset[pidx]      = aiu_NumPorts;
       aiu_NumCores[pidx]    = 1;
       aiu_NumPorts++;
   }
 }
%>
class concerto_test_cfg extends uvm_object;

   //////////////////
   //UVM Registery
   //////////////////   
   `uvm_object_param_utils(concerto_test_cfg)
   //////////////////
   //Properties
   //////////////////
   concerto_env_cfg m_concerto_env_cfg;  
   concerto_env     m_concerto_env;
   concerto_register_map_pkg::ral_sys_ncore m_regs;

   string chiaius_name_a [$] = {<%=all_chiaius_strname.join(',')%>};
   string ioaius_name_a [$] = {<%=all_ioaius_strname.join(',')%>};
   string ioaius_sysco_name_a [$] = {<%=all_ioaius_sysco_strname.join(',')%>};
   string axi4_withoutcache_name_a [$] = {<%=all_axi4_without_cache.join(',')%>};
   string diis_name_a [$] = {<%=all_diis_strname.join(',')%>};
   string dmis_name_a [$] = {<%=all_dmis_strname.join(',')%>};

   //common
   bit test_main_seq_iter=1;
   bit disable_boot_tasks;
   bit k_csr_access_only;  
   int chi_num_trans;
   int ioaiu_num_trans;
   int 	      chiaiu_en[int];
   int 	      ioaiu_en[int];
   string     chiaiu_en_str[];
   string     ioaiu_en_str[];
   string     chiaiu_en_arg;
   string     ioaiu_en_arg;
   bit sys_event_disable;
   bit sys_event_errdeten;//enable sysevent tiemoute err detection
   bit sysco_disable;
   int 	qos_threshold;
   int   reduce_mem_size;
   bit dmi_atomicDecErr;
   //DCE
   int 	dce_qos_threshold[int];
   string      dce_qos_threshold_str[];
   string      dce_qos_threshold_arg;
   //
   bit dii_sys_event_disable;
   bit dmi_sys_event_disable;
   //DMI
   int 	dmi_qos_threshold[int];
   string      dmi_qos_threshold_str[];
   string      dmi_qos_threshold_arg;
   int 	dmi_qos_rsved;  // qos threshold reserved for high priority
   int dmiusmc_policy;
   bit[<%=all_dmis_strname.length-1%>:0] dmi_allocen;
   bit[<%=all_dmis_strname.length-1%>:0] dmi_lookupen;
   bit[<%=obj.nAIUs-1%>:0] ccp_allocen;
   bit[<%=obj.nAIUs-1%>:0] ccp_lookupen;
   int starv_thres[<%=obj.nAIUs%>];
   bit ccp_update_cmd_disable;
   bit check_dvm_version = 0;

   int transorder_mode[<%=obj.nAIUs%>]; // 2: Pcie_order 3:strict request order
   //AIU
   bit en_chiaiu_coherency_via_reg;  
   static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
   static uvm_event ev_all_aiu_sysco_attached= ev_pool.get("ev_all_aiu_sysco_attached");
   int chiaiu_timeout_val;
   int ioaiu_timeout_val;
   int 	aiu_nbr_core[$] = '{<%=aiu_NumCores.join(',')%>}; // aiu_nbr_core[NUnitid] 
   int 	aiu_qos_offset[$] = '{<%=aiu_offset.join(',')%>}; // [Nunitid]= idx in table qos_threshold due to MPU case
   int 	aiu_qos_threshold[int];//example:[0,4,5,6..]  aiu0(mpu 4 ports)= table[0]...[3]  aiu1=table[4] aiu2=table[5]
   string      aiu_qos_threshold_str[];
   string      aiu_qos_threshold_arg;

   bit [31:0] agent_id,way_vec,way_full_chk;
   bit [31:0] agent_ids_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
   bit [31:0] wayvec_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
   int shared_ways_per_user;
   int way_for_atomic=0;
   int idxq[$];
   int sp_ways[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
   int sp_size[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
   bit sp_ns[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
   bit sp_en[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
   bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS]; 

   // Addr_Mgr
   addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];

   // CHI subsys seq to overwrite
   string chi_txn_seq_name; 
   string chi_subsys_vseq_name; 
   string io_subsys_inhouse_seq_name; 
   string io_subsys_vseq_name; 
   string chi_snp_seq_name; 
   string axi_txn_seq_name; 
   string axi_snp_seq_name; 
   string fsys_vseq_name;
   bit disable_override_svt_chi_txn;
   //sw credit manager
    parameter VALID_MAX_CREDIT_VALUE = 31;
    typedef int t_aCredit[int][string][int];

    int k_access_boot_region;
    int disable_sw_crdt_mgr_cls; // by default use swft credit class
    bit         use_new_csr;
    bit end_of_sim_fault_check = 0;

    int maxCredit;//max credit  sum of nDMI nDII nDCII credits
    //int aCredit_Cmd[int][string][int];//array to associate each aiu to DMI/DCE/DII credit aCredit[Aiuid]["DMI"DCE""DII"][Dmiid/Dceid/Diiid]
    //int aCredit_Mrd[int][string][int];//array to associate each dce to DMI credit aCredit[Dceid][Dmiid]
    t_aCredit aCredit_Cmd;
    t_aCredit aCredit_Mrd;
    <% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    int aCredit_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>[][];//array to associate each aiu to DMI/DCE/DII credit aCredit[Aiuid][Dmiid/Dceid/Diiid]
    <%  } %> //foreach pidx%>
   //////////////////
   //Methods
   //////////////////
   //constructor
   extern function new(string name = "concerto_test_cfg");
   extern function void set_env();
   
   extern virtual function void init_cfg();
   virtual function void report_phase(uvm_phase phase); return; endfunction; // TODO display all or specific chosen test cfgs  

   // Split function
   extern function void global_test_cfg();   
   extern function void chi_test_cfg();   
   extern function void ioaiu_test_cfg();   
   extern function void dce_test_cfg();   
   extern function void dmi_test_cfg();   

   // Tools Function
   extern function void parse_str(output string out[], input byte separator, input string in);

endclass: concerto_test_cfg

function concerto_test_cfg::new(string name = "concerto_test_cfg");

  super.new(name);
  set_env();
    
endfunction: new

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//               /\             /\            /\       
//              /  \           /  \          /  \
//             /    \         /    \        /    \
//            /  |   \       /  |   \      /  |   \
//           /   |    \     /   |    \    /   |    \
//          /    °     \   /    °     \  /    °     \
//         /____________\ /____________\/____________\
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// !!!!!!! IF unit SCB DOESN'T USE RAL TO CATCH THE CONFIGURATION
//  !!!!!!! BE SURE THAT ALL VALUES SET IN SCB IN THIS FILE IS SET IN THE REGISTER
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// #     # #     # #     #         ######  #     #    #     #####  #######
// #     # #     # ##   ##         #     # #     #   # #   #     # #
// #     # #     # # # # #         #     # #     #  #   #  #       #
// #     # #     # #  #  #         ######  ####### #     #  #####  #####
// #     #  #   #  #     #         #       #     # #######       # #
// #     #   # #   #     #         #       #     # #     # #     # #
//  #####     #    #     # ####### #       #     # #     #  #####  #######
////////////////////////////////////////////////////////////////////////////
function void concerto_test_cfg::set_env();
    if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal("fsys_scoreboard", "Could not find concerto_env_cfg object in UVM DB");
   end   
   if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal("fsys_scoreboard", "Could not find concerto_env_cfg object in UVM DB");
   end
endfunction:set_env

function void concerto_test_cfg::init_cfg();
    m_regs = m_concerto_env.m_regs;    
    csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();
    global_test_cfg();
    if (!k_access_boot_region) begin // in case of boot let all value by default in the scb
       dce_test_cfg();
       dmi_test_cfg();
       ioaiu_test_cfg();
       chi_test_cfg();
    end
endfunction: init_cfg

////////////////////////////////////////
//  #####
// #     #  #####   #          #     #####
// #        #    #  #          #       #
//  #####   #    #  #          #       #
//       #  #####   #          #       #
// #     #  #       #          #       #
//  #####   #       ######     #       #
// ////////////////////////////////////////
function void concerto_test_cfg::global_test_cfg();
    if (!$value$plusargs("en_chiaiu_coherency_via_reg=%0d",en_chiaiu_coherency_via_reg)) begin
        en_chiaiu_coherency_via_reg= 0; 
    end  
    if (!$value$plusargs("disable_override_svt_chi_txn=%0d",disable_override_svt_chi_txn)) begin
        disable_override_svt_chi_txn = 0; 
    end  
    if (!$value$plusargs("chi_txn_seq_name=%0s",chi_txn_seq_name)) begin
        chi_txn_seq_name = "chi_subsys_base_item"; 
    end  
    if (!$value$plusargs("chi_subsys_vseq_name=%0s",chi_subsys_vseq_name)) begin
        chi_subsys_vseq_name = "chi_subsys_random_vseq"; 
    end  
    if (!$value$plusargs("io_subsys_inhouse_seq_name=%0s",io_subsys_inhouse_seq_name)) begin
        io_subsys_inhouse_seq_name = "axi_master_pipelined_seq"; 
    end  
    if (!$value$plusargs("io_subsys_vseq_name=%0s",io_subsys_vseq_name)) begin
        io_subsys_vseq_name = "io_subsys_snps_vseq"; 
    end  
    if (!$value$plusargs("chi_snp_seq_name=%0s",chi_snp_seq_name)) begin
       chi_snp_seq_name = "chi_subsys_snoop_base_item"; 
    end  
    if (!$value$plusargs("axi_txn_seq_name=%0s",axi_txn_seq_name)) begin
        axi_txn_seq_name = "conc_base_svt_axi_master_transaction"; 
    end  
    if (!$value$plusargs("axi_snp_seq_name=%0s",axi_snp_seq_name)) begin
       axi_snp_seq_name = "cust_svt_axi_snoop_transaction"; 
    end 
    if (!$value$plusargs("fsys_vseq_name=%0s",fsys_vseq_name)) begin
       fsys_vseq_name = "fsys_main_traffic_virtual_seq"; 
    end 
    if (!$value$plusargs("reduce_addr_area=%d",reduce_mem_size)) begin
      reduce_mem_size=64;
    end else begin
       if (reduce_mem_size==1) begin
       reduce_mem_size=64;
       end
    end
    //`uvm_info("TEST_MAIN", $sformatf("reduce_mem_size:%0d",reduce_mem_size), UVM_LOW)
    
    if (!$value$plusargs("dmi_atomicDecErr=%d",dmi_atomicDecErr)) begin
       dmi_atomicDecErr=0;
    end

    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
    if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end
    if(!$value$plusargs("chiaiu_en=%s", chiaiu_en_arg)) begin
    <% var chiaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       chiaiu_en[<%=chiaiu_idx%>] = 1;
       <% chiaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(chiaiu_en_str, "n", chiaiu_en_arg);
       foreach (chiaiu_en_str[i]) begin
	  chiaiu_en[chiaiu_en_str[i].atoi()] = 1;
       end
    end
   
    if(!$value$plusargs("ioaiu_en=%s", ioaiu_en_arg)) begin
    <% var ioaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
       ioaiu_en[<%=ioaiu_idx%>] = 1;
       <% ioaiu_idx++; } %>
    <% } %>
    end else begin
       parse_str(ioaiu_en_str, "n", ioaiu_en_arg);
       foreach (ioaiu_en_str[i]) begin
	  ioaiu_en[ioaiu_en_str[i].atoi()] = 1;
          //`uvm_info("FULLSYS_TEST", $sformatf("ioaiu_en[%0d] = %0d", ioaiu_en_str[i].atoi(), ioaiu_en[ioaiu_en_str[i].atoi()]), UVM_NONE)
       end
    end

   if(!$value$plusargs("disable_boot_tasks=%d", disable_boot_tasks)) begin
      disable_boot_tasks =0;
   end
   if(!$value$plusargs("test_main_seq_iter=%d", test_main_seq_iter)) begin
      test_main_seq_iter =1;
   end
   if(!$value$plusargs("k_csr_access_only=%d",k_csr_access_only))begin
       k_csr_access_only = 0;
    end
   // Global test cfg 
   if(!$value$plusargs("sys_event_disable=%d", sys_event_disable)) begin
       sys_event_disable = 0;
   end
   if(!$value$plusargs("sys_event_errdeten=%d", sys_event_errdeten)) begin
       sys_event_errdeten = 0;
   end
   if(!$value$plusargs("syso_disable=%d", sysco_disable)) begin
       sysco_disable = 0;
   end
    if(!$value$plusargs("dii_sys_event_disable=%d", dii_sys_event_disable)) begin
       dii_sys_event_disable = 0;
   end  
    if(!$value$plusargs("dmi_sys_event_disable=%d", dmi_sys_event_disable)) begin
       dmi_sys_event_disable = 0;
   end  
   if (sys_event_disable ) begin
       dii_sys_event_disable = 1;
       dmi_sys_event_disable = 1;
   end 
   if (!$value$plusargs("disable_sw_crdt_mgr_cls=%0d",disable_sw_crdt_mgr_cls)) begin
        disable_sw_crdt_mgr_cls = 0;
   end

    if(!$value$plusargs("use_new_csr=%d",use_new_csr))begin
       use_new_csr= 1;
    end
   if(!$value$plusargs("k_access_boot_region=%d",k_access_boot_region)) k_access_boot_region = 0;

   if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
      <% for(var pidx = 0 ; pidx < obj.nDCEs; pidx++) { %>
             dce_qos_threshold[<%=pidx%>] = qos_threshold;
      <% } %>
      <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
            dmi_qos_threshold[<%=pidx%>] = 64;
      <% } %>
      <% for(var pidx = 0 ; pidx < aiu_NumPorts; pidx++) { %>
            aiu_qos_threshold[<%=pidx%>] = 64;
      <% } %>
   end

   if(!$value$plusargs("aiu_qos_threshold=%s", aiu_qos_threshold_arg)) begin
    <% for(var pidx = 0 ; pidx < aiu_NumPorts; pidx++) { %>
       aiu_qos_threshold[<%=pidx%>] = 64;
    <% } %>
   end
   else begin
      parse_str(aiu_qos_threshold_str, "n", aiu_qos_threshold_arg);
      foreach (aiu_qos_threshold_str[i]) begin
	     aiu_qos_threshold[i] = aiu_qos_threshold_str[i].atoi();
      end
   end
    // OVERWRITE
    <% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
       <%if (! obj.AiuInfo[pidx].fnEnableQos) { %>
        <% for(var cor_idx = 0 ; cor_idx <  aiu_NumCores[pidx]; cor_idx++) { %>
             aiu_qos_threshold[<%=pidx+cor_idx%>] =  -1;
        <%}%>
      <%}%>
    <%}%>

    if (k_access_boot_region || k_csr_access_only) begin // case test boot memregion disable CSR setup
       disable_boot_tasks = 1;
    end

    if (disable_boot_tasks) disable_sw_crdt_mgr_cls=1;

    void'($value$plusargs("check_dvm_version=%0d",check_dvm_version));
    if (!$value$plusargs("end_of_sim_fault_check=%0b",end_of_sim_fault_check)) begin
        end_of_sim_fault_check = 0; 
    end  
endfunction:global_test_cfg

function void concerto_test_cfg::chi_test_cfg();
   if (!$value$plusargs("chiaiu_timeout_val=%d",chiaiu_timeout_val)) begin
        chiaiu_timeout_val= 2000;
   end
endfunction:chi_test_cfg

function void concerto_test_cfg::ioaiu_test_cfg();
   int ccp_lookupen_val;
   int ccp_allocen_val;

   if ($test$plusargs("stress_starv")) begin 
      foreach(starv_thres[i]) begin 
        starv_thres[i] = $urandom_range(0,5);
      end
   end else begin 
      foreach(starv_thres[i]) begin 
        starv_thres[i] = 16;
      end
   end

   ccp_lookupen  = {<%=obj.nAIUs%>{1'b1}};// by default enable
   ccp_allocen  = {<%=obj.nAIUs%>{1'b1}};// by default enable
   if (!$value$plusargs("ioaiu_timeout_val=%d",ioaiu_timeout_val)) begin
      ioaiu_timeout_val= 2000;
   end
   if(($value$plusargs("ccp_lookupen=%0d",ccp_lookupen_val))) begin
      ccp_lookupen  = {<%=obj.nAIUs%>{ccp_lookupen_val}};
   end
   if(($value$plusargs("ccp_allocen=%0d",ccp_allocen_val))) begin
      ccp_allocen  = {<%=obj.nAIUs%>{ccp_allocen_val}};
   end
   if($test$plusargs("rand_alloc_lookup")) begin
      int rand_value;
      rand_value = $urandom_range(0,((2**<%=obj.nAIUs%>)-1));
      ccp_lookupen = rand_value;
      rand_value = $urandom_range(0,((2**<%=obj.nAIUs%>)-1));
      ccp_allocen = rand_value;
   end
   
   if(!($value$plusargs("update_cmd_disable=%0d",ccp_update_cmd_disable))) begin
     <% if (obj.initiatorGroups.length >1) { %>
       ccp_update_cmd_disable = 1;// if connectivity feature disable update channel in the proxy cache due to issue around dii when use allocate cache
   <%} else {%>
       ccp_update_cmd_disable = 0;
   <%}%>
   end
  

   begin:_transorder // use only in case of NCAIU agent // ACE always reset value = strictreq order
   int transorder;
   int j;
   // use only in case of NCAIU
      foreach (transorder_mode[j]) begin:_foreach_transorder // foreach AIU but use only by NCAIU
         if($test$plusargs("dii_cmo_test")) begin 
<% if ((obj.IoaiuInfo.length > 0) && (obj.testBench != "io_aiu")) { %>
         //CONC-16770 - Guarding for IOAIUp masters
             if(!((j > (addr_trans_mgr_pkg::addrMgrConst::NUM_CHI_MASTERS-1)) && (addr_trans_mgr_pkg::addrMgrConst::io_subsys_owo_en[j - addr_trans_mgr_pkg::addrMgrConst::NUM_CHI_MASTERS]==1))) begin
                 transorder_mode[j]=3; continue; 
             end
<% } else { %>
             transorder_mode[j]=3; continue; 
<% } %>
         end
         if(!$value$plusargs("ace_transorder_mode=%d", transorder)) begin
            randcase
               10:    transorder= 3;  // 2: Pcie_order 3:strict request order
               90:    transorder= 2; 
            endcase
         end
<% if ((obj.IoaiuInfo.length > 0) && (obj.testBench != "io_aiu")) { %>
         if(j > (addr_trans_mgr_pkg::addrMgrConst::NUM_CHI_MASTERS-1)) begin // starts io masters
             if(addr_trans_mgr_pkg::addrMgrConst::io_subsys_owo_en[j - addr_trans_mgr_pkg::addrMgrConst::NUM_CHI_MASTERS]==1) begin // CONC-16057 - strict mode is illegal for the IOAIUp(owo==true).
                 transorder= 2; 
             end
         end
<% } %>
         transorder_mode[j]=transorder;
      end:_foreach_transorder
   end:_transorder

endfunction:ioaiu_test_cfg

function void concerto_test_cfg::dce_test_cfg();

  //DCE test args
   // Overwrite if specific dce_qos_threhsold
  if(!$value$plusargs("dce_qos_threshold=%s", dce_qos_threshold_arg)) begin
    <% for(var pidx = 0 ; pidx < obj.nDCEs; pidx++) { %>
        <% if (obj.DceInfo[pidx].fnEnableQos) { %> 
           dce_qos_threshold[<%=pidx%>] =  m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUQOSCR0.EventThreshold.get_reset();
        <% } %>
    <% } %>
    end
    else begin
       parse_str(dce_qos_threshold_str, "n", dce_qos_threshold_arg);
       foreach (dce_qos_threshold_str[i]) begin
	     dce_qos_threshold[i] = dce_qos_threshold_str[i].atoi();
       end
    end
    // Overwrite if QOS is disable
    <% for(var pidx = 0 ; pidx < obj.nDCEs; pidx++) { %>
        <% if ( !obj.DceInfo[pidx].fnEnableQos) { %> 
           dce_qos_threshold[<%=pidx%>] = -1;   // if QOS is disable set -1
        <% } else {%> // setup DCE env
         m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_qoscr_event_threshold=dce_qos_threshold[<%=pidx%>];
        <%}%>
    <% } %>

endfunction:dce_test_cfg

function void concerto_test_cfg::dmi_test_cfg();
    
      int bit_offset;
      bit dmi_scb_en = m_concerto_env_cfg.m_dmi0_env_cfg.has_scoreboard;
  //DMI test args

    if(!$value$plusargs("dmi_qos_threshold=%s", dmi_qos_threshold_arg)) begin
    <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
       dmi_qos_threshold[<%=pidx%>] =  <%=(obj.DmiInfo[pidx].fnEnableQos == 1) ? `m_regs.${obj.DmiInfo[pidx].strRtlNamePrefix}.DMIUQOSCR0.EventThreshold.get_reset();` :"-1;"%>
      <%}%>
    end
    else begin
       parse_str(dmi_qos_threshold_str, "n", dmi_qos_threshold_arg);
       foreach (dmi_qos_threshold_str[i]) begin
	       dmi_qos_threshold[i] = dmi_qos_threshold_str[i].atoi();
       end
    end
    // OVERWRITE
    if(!$value$plusargs("dmi_qos_rsved=%h", dmi_qos_rsved)) begin
       dmi_qos_rsved = 'h80000101; // 8 QOS threshold val / 1 RTT & WTT reserved for high priority
    end

    // if not enable QOS set -1 to disable boot setup
      <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
       dmi_qos_threshold[<%=pidx%>] =  <%=(obj.DmiInfo[pidx].fnEnableQos == 1) ? `dmi_qos_threshold[${pidx}];` :"-1;"%>
      <%}%>


    dmi_lookupen={<%=all_dmis_strname.length%>{1'b1}};
    if($test$plusargs("dmi_alloc_dis")) begin
       dmi_allocen=0;
    end else if($test$plusargs("rand_alloc_lookup")) begin
      int rand_value;
      rand_value = $urandom_range(0,((2**<%=all_dmis_strname.length%>)-1));
      dmi_lookupen = rand_value;
      rand_value = $urandom_range(0,((2**<%=all_dmis_strname.length%>)-1));
      dmi_allocen = rand_value;
    end else begin // by default enable DMI cache 
       dmi_allocen={<%=all_dmis_strname.length%>{1'b1}};
    end

    if($test$plusargs("dmiusmc_policy_test")) begin
        std::randomize(dmiusmc_policy) with {dmiusmc_policy dist { 1:=0, 2:=20, 4:=80, 8:=0, 16:=0};};// RdAllocDisable, WrAllocDisable have a direct tests
    end else begin //by default ALL enable
       dmiusmc_policy =0;// data[4]:WrAllocDisable , data[3]:RdAllocDisable , data[2]:DtyWrAllocDisable , data[1]:ClnWrAllocDisable , data[0]:TOFAllocDisable
    end
 <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
 //#Check.FSYS.SMC.TOFAllocDisable
 //#Check.FSYS.SMC.ClnWrAllocDisable
 //#Check.FSYS.SMC.DtyWrAllocDisable
 //#Check.FSYS.SMC.RdAllocDisable
 //#Check.FSYS.SMC.WrAllocDisable     
      begin: dmi<%=pidx%>
  <% if(obj.DmiInfo[pidx].useCmc) { %>
      if(dmi_scb_en) m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.alloc_en  = dmi_allocen[<%=pidx%>] ;
      if(dmi_scb_en) m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.lookup_en = dmi_lookupen[<%=pidx%>];

      if(dmiusmc_policy==2) begin
      if(dmi_scb_en)  m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.ClnWrAllocDisable = 1;
       bit_offset = m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCAPR.ClnWrAllocDisable.get_lsb_pos();
       dmiusmc_policy[bit_offset]=1;
      end		
      if(dmiusmc_policy==4) begin
      if(dmi_scb_en)  m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.DtyWrAllocDisable = 1;
       bit_offset = m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCAPR.DtyWrAllocDisable.get_lsb_pos();
       dmiusmc_policy[bit_offset]=1;
      end
      if($test$plusargs("dmi_rdalloc_dis")) begin
      if(dmi_scb_en)  m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.RdAllocDisable = 1;
       bit_offset = m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCAPR.RdAllocDisable.get_lsb_pos();
       dmiusmc_policy[bit_offset]=1;
      end		
      if($test$plusargs("dmi_wralloc_dis")) begin
      if(dmi_scb_en)  m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.WrAllocDisable = 1;
       bit_offset = m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCAPR.WrAllocDisable.get_lsb_pos();
       dmiusmc_policy[bit_offset]=1;
      end	
    <% } %>
      end: dmi<%=pidx%>						  
  <% } %>		

    // SCRATCH PAD & WAY PARTITIONING 				  
   for(int i=0; i<addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS; i++) begin:_foreach_dmis
       int max_way_partitioning;
       if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcsp[i]) begin  
          // Enabling and configuring Scratchpad using force
          if ($test$plusargs("all_ways_for_sp")) begin
              sp_ways[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i];
          end
          if ($test$plusargs("full_small_sp")) begin
              sp_ways[i] = 1;// to test with small scratchpad to be able to use all the scratchpad
          end else if ($test$plusargs("all_ways_for_cache")) begin
              sp_ways[i] = 0;
          end else begin
              randcase
                  70 : sp_ways[i] = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]/2);
                  30 : sp_ways[i] = $urandom_range(1,(addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1));
              endcase
          end
          `uvm_info("TEST_MAIN", $sformatf("For DMI%0d SP_WAY : 32'h%8h",i,sp_ways[i]), UVM_LOW)
       end

       if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i]) begin  
          way_for_atomic = $urandom_range(sp_ways[i],addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1);
       end
       if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcwp[i]) begin  
          way_full_chk = (sp_ways[i] == 0) ? 0 : ((1 << sp_ways[i]) - 1);
          for(int k=0; k<<%=obj.nAIUs%>;k++) begin
             agent_ids_assigned_q[i].push_back(k);  
          end
          agent_ids_assigned_q[i].shuffle();  
         max_way_partitioning = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i] > <%=obj.nAIUs%>) ? <%=obj.nAIUs%> : addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
         for( int j=0;j<max_way_partitioning /*addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i]*/;j++) begin
             if ($test$plusargs("all_way_partitioning")) begin
                if((j==0)&&(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[j]==0)) begin 
                   agent_id = 32'h8000_0000 |  agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                else     begin agent_id = 32'h0000_0000 |  agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
             end else begin
                randcase
                  10 : begin agent_id = 32'h0000_0000 | agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                  90 : begin agent_id = 32'h8000_0000 | agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                endcase
             end
             `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d wp_agentid 32'h%8h",i,j,agent_ids_assigned_q[i][j]), UVM_LOW)


          end // for Waypart Registers
          //CONC-15114 - Review this condition since now shared_ways_per_user is same irrespective of condition. Fix in the else part by removing "-1" looks proper because "-1" was causing 0 value (bad programming of way vector) being programmed.
          //if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i]==0) begin
          //   shared_ways_per_user = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]/addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
          //end else begin
             shared_ways_per_user = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i] - sp_ways[i])/addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
          //end
          for( int j=0;j<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];j++) begin
              if ($test$plusargs("all_way_partitioning")&&(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[j]==0)) begin
                 way_vec = ((1<<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i])-1);
              end else begin
                 way_vec = ((1<<$urandom_range(1,shared_ways_per_user)) - 1) << ((shared_ways_per_user)*j + sp_ways[i]);
              end
              if ($test$plusargs("no_way_partitioning")) way_vec=0;
		      `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
              wayvec_assigned_q[i].push_back(way_vec);
              way_full_chk |=way_vec;
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b num ways in DMI:%0d",i,j,way_full_chk,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]), UVM_LOW)
          end

          for( int j=0;j<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];j++) begin
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b count ones:%0d",i,j,way_full_chk,$countones(way_full_chk)), UVM_LOW)
              way_vec = wayvec_assigned_q[i].pop_front;
              if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i] && $countones(way_full_chk)>=addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]) begin  
                 way_vec[way_for_atomic] = 1'b0;
                 `uvm_info("TEST_MAIN", $sformatf("For DMI%0d with AtomicEngine way:%0d/%0d is unallocated, so that atomic txn can allocate",i,way_for_atomic,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]), UVM_LOW)
              end
              if(way_vec==0) agent_ids_assigned_q[i][j][31] = 0;
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
              wayvec_assigned_q[i].push_back(way_vec);

              case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                 <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                  if(dmi_scb_en) begin
                                     m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_way[j] = way_vec;
                                  end
                                  <%}%>end
         <%}%>endcase

             case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                 if(dmi_scb_en) begin
                                    m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j] = agent_ids_assigned_q[i][j][31];
                                    m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_id[j] = agent_ids_assigned_q[i][j][30:0];
                                    if ($test$plusargs("no_way_partitioning")) m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j]=0;
                                    end
                                <%}%>end
        <%}%>endcase
          end
       end // if (addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcwp[i])
       foreach(wayvec_assigned_q[i][j]) begin
           `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d way_vec 32'h%8h wp_agentid 32'h%8h",i,j,wayvec_assigned_q[i][j],agent_ids_assigned_q[i][j]), UVM_LOW)
       end


       // Configure Scratchpad memories
       if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcsp[i]) begin  
        // #Stimulus.FSYS.DMI_ScratchPad
         idxq = csrq.find_index(x) with (  (x.unit.name == "DMI") && (x.mig_nunitid == addr_trans_mgr_pkg::addrMgrConst::dmi_intrlvgrp[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][i]) );
         if(idxq.size() == 0) begin
              `uvm_error("EXEC_INHOUSE_BOOT_SEQ", $sformatf("DMI%0d Interleaving group %0d not found", i, addr_trans_mgr_pkg::addrMgrConst::dmi_intrlvgrp[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][i]))
         end
          k_sp_base_addr[i] = {csrq[idxq[0]].upp_addr,csrq[idxq[0]].low_addr,12'h0}; // 12bits because GPRBLR reg = "Lower order bits 43:12 of the base address of the region"
          sp_ns[i] = csrq[idxq[0]].nsx;
          sp_size[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcSet[i] * sp_ways[i];
          sp_en[i] = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i] && !($test$plusargs("all_ways_for_cache"))) ? 32'h1 : 32'h0;
	       if(dmi_scb_en) begin 
               case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) { %>
                 <%=sidx%> : begin //dmi<%=sidx%>
                             <% if (obj.DmiInfo[sidx].useCmc && obj.DmiInfo[sidx].ccpParams.useScratchpad) {%>
                                int total_dmis;
                               // find IG with DMI UnitId & MIG_id
                                  foreach (addr_trans_mgr_pkg::addrMgrConst::intrlvgrp_vector[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][mig_id]) begin:_foreach_mig_ig<%=sidx%>
                                  int nDMIs_per_ig=  addr_trans_mgr_pkg::addrMgrConst::intrlvgrp_vector[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][mig_id];
                                    if   ((<%=sidx%> >= total_dmis) && (<%=sidx%> < total_dmis + nDMIs_per_ig )) begin:_dmi_id_mig_match<%=sidx%>
                                     int amig_set = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs;
                                     int amif_way = nDMIs_per_ig; 
                                     int amif_func = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[nDMIs_per_ig];
                                    `uvm_info("TEST_CFG:", $sformatf("DMI%0d amigs_set:%0d amif_way:%0d amif_func:%0d",<%=sidx%>,amig_set,amif_way,amif_func), UVM_NONE)
                                     addr_trans_mgr_pkg::addrMgrConst::set_dmi_spad_intrlv_info(amig_set,amif_way,amif_func,<%=sidx%>);
                                     break;
                                     end:_dmi_id_mig_match<%=sidx%>  
                                    total_dmis += nDMIs_per_ig;
                                end:_foreach_mig_ig<%=sidx%>
                               if(sp_ways[<%=sidx%>] > 0) begin
                                   m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_enabled     = sp_en[<%=sidx%>];
                                   m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.lower_sp_addr  = (addrMgrConst::gen_spad_intrlv_rmvd_addr(k_sp_base_addr[<%=sidx%>],<%=sidx%>)) >> <%=obj.wCacheLineOffset%>;
                                   m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_ns  = sp_ns[<%=sidx%>];
                                   m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_ways        = sp_ways[<%=sidx%>];
                                   m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.create_SP_q();
		                         end
                             <% } %>
                             end   
               <%} %>
              endcase
	       end
          //MEM_CONSISTENCY
          if (sp_en[i]) begin
            m_concerto_env_cfg.m_mem_checker_cfg.sp_base_addr[i] = (addrMgrConst::gen_spad_intrlv_rmvd_addr(k_sp_base_addr[i],i)) >> <%=obj.wCacheLineOffset%>;
            m_concerto_env_cfg.m_mem_checker_cfg.sp_ways[i] = sp_ways[i];
            m_concerto_env_cfg.m_mem_checker_cfg.sp_size[i] = sp_size[i];
          end

          k_sp_base_addr[i] = k_sp_base_addr[i] >> (<%=obj.wCacheLineOffset%>);
          m_concerto_env_cfg.k_sp_base_addr[i] = k_sp_base_addr[i];

         `uvm_info("TEST_MAIN", $psprintf("test_cfg scratchpad address base k_sp_base_addr[dmi %0d] = %0h",i,k_sp_base_addr[i]), UVM_MEDIUM)
       end // if (addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcsp[i])
   end:_foreach_dmis // for nDMIs
endfunction: dmi_test_cfg

////////////////////////////////////////////////
//#######
//   #      ####    ####   #        ####
//   #     #    #  #    #  #       #
//   #     #    #  #    #  #        ####
//   #     #    #  #    #  #            #
//   #     #    #  #    #  #       #    #
//   #      ####    ####   ######   ####
////////////////////////////////////////////////
function void concerto_test_cfg::parse_str(output string out [], input byte separator, input string in);
   int index [$]; // queue of indices (begin, end) of characters between separator

   if((in.tolower() != "none") && (in.tolower() != "null")) begin
      foreach(in[i]) begin // find separator
         if (in[i]==separator) begin
            index.push_back(i-1); // index of byte before separator
            index.push_back(i+1); // index of byte after separator
         end
      end
      index.push_front(0); // begin index of 1st group of characters
      index.push_back(in.len()-1); // last index of last group of characters

      out = new[index.size()/2];

      // grep characters between separator
      foreach (out[i]) begin
         out[i] = in.substr(index[2*i],index[2*i+1]);
      end
   end // if ((in.tolower() != "none") || (in.tolower() != "null"))

endfunction : parse_str
