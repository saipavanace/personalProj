<%

var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var numBootIoAiu = 0; // Number of IOAIUs with csr access
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var ncaiu0;   // strRtlNamePrefix of ncaiu0
var csrAccess_ioaiu;  // IOAIU with csr access
var csrAccess_chiaiu;  // IOAIU with csr access
var idxIoAiuWithPC = 0; // To get valid index of NCAIU with ProxyCache
var numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
var idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
var aceIdx = [];
var clocks = [];
var clocks_freq = [];
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
const aiu_axiInt = [];
const ncAiuName = [];


for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
  if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
      aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
  } else {
      aiu_NumCores[pidx]    = 1;
  }
}

var ncaiu_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if (obj.AiuInfo[pidx].fnNativeInterface.indexOf('CHI') < 0) {
        if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
            aiu_axiInt[pidx] = new Array(obj.AiuInfo[pidx].interfaces.axiInt.length);
            for (var i=0; i<obj.AiuInfo[pidx].interfaces.axiInt.length; i++) {
              aiu_axiInt[pidx][i] = obj.AiuInfo[pidx].interfaces.axiInt[i];
            }
            ncAiuName[ncaiu_idx] = obj.AiuInfo[pidx].strRtlNamePrefix + "_0";
        } else {
            aiu_axiInt[pidx]    = new Array(1);
            aiu_axiInt[pidx][0] = obj.AiuInfo[pidx].interfaces.axiInt;
            ncAiuName[ncaiu_idx]  = obj.AiuInfo[pidx].strRtlNamePrefix;
        }
        ncaiu_idx++;
    }
}

// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
         if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
          numChiAiu++ ; numCAiu++ ; 
       }
    else
       { numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { if (numACEAiu==0) { aceaiu0=obj.AiuInfo[pidx].strRtlNamePrefix; }
                                                            numCAiu++ ; numACEAiu++; }
         else {  if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                    if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
                 } else {
                    if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
                 }
                 numNCAiu++ ; }
         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
         if(obj.AiuInfo[pidx].fnCsrAccess) numBootIoAiu++;
         
       }
}
var chi_idx=0;
var ace_idx=0;
var io_idx=0;
var found_csr_access_chiaiu = 0;
var found_csr_access_ioaiu = 0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface != "CHI-A")&&(obj.AiuInfo[pidx].fnNativeInterface != "CHI-B" && obj.AiuInfo[pidx].fnNativeInterface != "CHI-E")) 
    {
        if(obj.AiuInfo[pidx].fnNativeInterface == "ACE")
        {
            if(ace_idx == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
            aceIdx[ace_idx] = io_idx;
            ace_idx++;
        }
        else
        {
            if(io_idx == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
        }
        if((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_ioaiu = io_idx;    // TODO check usage
            found_csr_access_ioaiu = 1;
        }
        io_idx++;
    } else {
        if((found_csr_access_chiaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
       csrAccess_chiaiu = chi_idx;
       found_csr_access_chiaiu = 1;
        }
        chi_idx++;
    }
} 
%>


//File: concerto_fullsys_pcie_prod_consu.svh

<%  if((obj.INHOUSE_OCP_VIP)) { %>
import ocp_agent_pkg::*;
<%  } %>

<%  if((obj.INHOUSE_APB_VIP)|| (obj.useResiliency)) { %>
//import apb_agent_pkg::*;
<%  } %>

////////////////////////////////////////////////////////////////////////////////
/// PCIE PRODUCER-CONSUMER STRESS TEST
/// cf https://arterisip.atlassian.net/browse/CONC-12569
///
///  plusargs:
// +pcie_prod_consu_stress_test= 0 (coh) ||  1(noncoh)
// +"producer_ncaiu"="0n2" 
// +"consumer_ncaiu"="1n3"
// optional: axlen_bytes=256 // 64B, 256B, 512B etc...
//
// Producer IOAIU0 => Consumer IOAIU1
// Producer IOAIU2 => Consumer IOAIU3
//
// AXID=0 read & write
//
// init Producer set Flag set to 0 
// repeat "prod_consu_iteration" times
// Producer WRITE data @0 ... last addr with (addr + prod_consu_iteration index) & Consumer Read Flag
// Produce at the end of data set the flag to 1
// Consumer read flag=1 => READ @last addr ... 0  & Check data 
// Consumer at the end of data set flag to 0
//
// !!! num_trans = nbr of data transfert !!!
parameter SYS_nSysCacheline   = <%=Math.pow(2, obj.wCacheLineOffset)%>;
parameter DATA_SIZE           = 64; /// !!! DATA_SIZE > address size !!!
class concerto_fullsys_pcie_prod_consu_test extends concerto_fullsys_test;

    //////////////////
    //Properties
    //////////////////
   int        producer_ncaiu[int]; // [nunitid]
   string     producer_ncaiu_str[];
   string     producer_ncaiu_arg;
   int        consumer_ncaiu[int]; // [nunitid]
   string     consumer_ncaiu_str[];
   string     consumer_ncaiu_arg;
   int        nbr_prod_consu;
   bit init[int];
   int prod_consu_iter; // nbr of iteration between prod & consumer
   int axlenB;   
   int nbr_cacheline_by_txn;   
  addrMgrConst::addrq data_addrq[int]; // data_addrq[prod_consu index][queue]
  addrMgrConst::addrq flag_addrq[int]; // flag_addr[prod_consu index][queue]

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_fullsys_pcie_prod_consu_test)
    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_fullsys_pcie_prod_consu", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    // HOOK
    extern  virtual task exec_inhouse_seq(uvm_phase phase);
    // FUNCTION
    extern  virtual function void setup_addrq();
    <% for(var idx = 0, ncidx=0,ioidx=0; idx < obj.nAIUs; idx++) { %>
    <% if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
    <%   if(!(obj.AiuInfo[idx].fnNativeInterface == "ACE")) { %>
        extern task producer_ncaiu<%=ncidx%>();
        extern task consumer_ncaiu<%=ncidx%>();
        <% ncidx++; } // if not ACE%> 
        ioaiu<%=ioidx%>_axi_agent_pkg::axi_virtual_sequencer  ioaiu_vseqr<%=ioidx%>;
    <% ioidx++; }  // IF not CHI%>
    <%}%> // Foreach IOAIU

endclass: concerto_fullsys_pcie_prod_consu_test

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_fullsys_pcie_prod_consu_test::new(string name = "concerto_fullsys_pcie_prod_consu", uvm_component parent = null);
    super.new(name, parent);
    if(    !$test$plusargs("pcie_prod_consu_stress_test")
        && !$test$plusargs("producer_ncaiu") 
        && !$test$plusargs("consumer_ncaiu")
        ) begin
        `uvm_error("New PCIE producer consumer","You don't set the correct plusargs with this test case")
    end
    if(!$value$plusargs("prod_consu_iter=%0d",prod_consu_iter))
       prod_consu_iter=2;
    if(!$value$plusargs("axlen_bytes=%0d",axlenB)) begin
       nbr_cacheline_by_txn=1;
       axlenB=64;
    end
    else begin
       nbr_cacheline_by_txn= axlenB/SYS_nSysCacheline;// ex: 256B/64B = 4 cacheline
    end 
endfunction: new

///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 
//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_pcie_prod_consu_test::build_phase(uvm_phase phase);
    string msg_idx;
    int nbr_producer;
    int nbr_consumer;

    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);
`ifdef USE_VIP_SNPS
     if (m_concerto_env_cfg.has_axi_vip_snps) `uvm_error("BUILD PCIE producer consumer","Producer consumer with SNPS IOAIU VIP not yet implemented")
`endif 
    if($value$plusargs("producer_ncaiu=%s", producer_ncaiu_arg)) begin
          parse_str(producer_ncaiu_str, "n", producer_ncaiu_arg);
          foreach (producer_ncaiu_str[i]) begin
            nbr_producer++;
            producer_ncaiu[producer_ncaiu_str[i].atoi()] = nbr_producer;
            init[producer_ncaiu[producer_ncaiu_str[i].atoi()]]=1;
          end
    end

    if($value$plusargs("consumer_ncaiu=%s", consumer_ncaiu_arg)) begin
          parse_str(consumer_ncaiu_str, "n", consumer_ncaiu_arg);
          foreach (consumer_ncaiu_str[i]) begin
            nbr_consumer++;
            consumer_ncaiu[consumer_ncaiu_str[i].atoi()] = nbr_consumer;
          end
    end
 
    if (nbr_consumer != nbr_producer) begin
             `uvm_error("BUILD PCIE producer consumer",$sformatf("Don't have the same number of producer/consumer =%0d/%0d",nbr_producer,nbr_consumer))
    end

     foreach(producer_ncaiu[j]) 
         `uvm_info("Build", $sformatf("enable producer ioaiu%0d producer_ncaiu=%0d",j,producer_ncaiu[j]), UVM_NONE)
     
     foreach(consumer_ncaiu[j]) 
         `uvm_info("Build", $sformatf("enable consumer ioaiu%0d consumer_ncaiu=%0d",j,consumer_ncaiu[j]), UVM_NONE)
    
    `uvm_info("Build", "Exited Build Phase", UVM_LOW);

endfunction: build_phase

function void concerto_fullsys_pcie_prod_consu_test::start_of_simulation_phase(uvm_phase phase);
 super.start_of_simulation_phase(phase);
 
    <% for(var idx = 0, ioidx=0; idx < obj.nAIUs; idx++) { 
    if(!((obj.AiuInfo[idx].fnNativeInterface.match('CHI')))) { %>
     if(!(uvm_config_db#(ioaiu<%=ioidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=ioidx%>[0]" ),.value( ioaiu_vseqr<%=ioidx%> ) ))) begin
     `uvm_error(get_name(), "Cannot get ioaiu_vseqr<%=ioidx%>[0]")
     end
    <% ioidx++; }// IF not CHI %> 
    <%} // Foreach IOAIU%> 
     
endfunction: start_of_simulation_phase

////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   ##### 
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
task concerto_fullsys_pcie_prod_consu_test::exec_inhouse_seq(uvm_phase phase);
         setup_addrq();
         fork
          <% for(var idx = 0, ncidx=0; idx < obj.nAIUs; idx++) { 
           if(!((obj.AiuInfo[idx].fnNativeInterface.match('CHI')) || (obj.AiuInfo[idx].fnNativeInterface == "ACE"))) { %>
           if (producer_ncaiu[<%=ncidx%>]) producer_ncaiu<%=ncidx%>();
           if (consumer_ncaiu[<%=ncidx%>]) consumer_ncaiu<%=ncidx%>();
           <% ncidx++; }// IF not CAIU %> 
           <%}// Foreach AIU%> 
         join
endtask:exec_inhouse_seq
////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
function void concerto_fullsys_pcie_prod_consu_test::setup_addrq();
// CREATE data_addrq & flag_addr 
// with pcie_prod_consu_stress_test addr_manager generate:
// 1- first region as coh with flag order (endpoint order) 
// 2- second region as coh with data order (relax order)
bit[DATA_SIZE-1:0] flag_addr = addrMgrConst::memregions_info[0].start_addr;
bit[DATA_SIZE-1:0] data_addr = addrMgrConst::memregions_info[1].start_addr;
foreach (producer_ncaiu[j]) begin:_foreach_producer
      for (int i=0; i<test_cfg.ioaiu_num_trans;i++) begin
        repeat(nbr_cacheline_by_txn) begin:_repeat
         `uvm_info("setup_addrq", $sformatf("data_addrq[%0d][%0d]=@%0h ",producer_ncaiu[j],i,data_addr), UVM_NONE)
         data_addrq[producer_ncaiu[j]].push_back(data_addr);
         data_addr += (1<< <%=obj.wCacheLineOffset%>);
        end:_repeat
      end
      `uvm_info("setup_addrq", $sformatf("flag_addrq[%0d][0]=@%0h ",producer_ncaiu[j],flag_addr), UVM_NONE)
      flag_addrq[producer_ncaiu[j]].push_back(flag_addr);
      flag_addr += (1<< <%=obj.wCacheLineOffset%>);
  end:_foreach_producer

endfunction:setup_addrq

<% for(var idx = 0, ncidx=0,ioidx=0; idx < obj.nAIUs; idx++) { 
    if(!((obj.AiuInfo[idx].fnNativeInterface.match('CHI')) || (obj.AiuInfo[idx].fnNativeInterface == "ACE"))) { %>
task concerto_fullsys_pcie_prod_consu_test::producer_ncaiu<%=ncidx%>();
     // TASK : 
     // if init write flag=0
     //   PRODUCER IOAIU if read flag=0  repeat (test_cfg.ioaiu_num_trans) write addr:data_addr[!!!start!!! ..end] data:addr+iter_idx  END write flag=1
     int iteration=0;
     int axlen=((axlenB*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA)-1;// ex: 256Bytes*8 / 128bits = axlen
     /// !!! Don't use MPU => coreid=0 !!!
     ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq axi_rdonce_seq<%=ncidx%>;
     ioaiu<%=ioidx%>_axi_agent_pkg::axi_rresp_t rresp;
     bit [ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA-1:0] rdata[(SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA]; 
     ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_master_writeunique_seq axi_master_writeunique_seq[int];

     // SETUP WRITE SEQ
      for (int i=0; i<test_cfg.ioaiu_num_trans+1;i++) begin  //num_trans +1 => write  data[num_trans] + flag
     axi_master_writeunique_seq[i] = ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_master_writeunique_seq::type_id::create($sformatf("axi_master_writeunique_seq_%0d",i));
     axi_master_writeunique_seq[i].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_axi_master_agent.m_write_addr_chnl_seqr;
     axi_master_writeunique_seq[i].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_axi_master_agent.m_write_data_chnl_seqr;
     axi_master_writeunique_seq[i].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_axi_master_agent.m_write_resp_chnl_seqr;
     axi_master_writeunique_seq[i].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioidx%>[0]; 
     // COMMMON SETUP:
     axi_master_writeunique_seq[i].get_addr_from_test = 1;
     axi_master_writeunique_seq[i].get_data_from_test = 1;
     axi_master_writeunique_seq[i].k_num_write_req = 1;
     axi_master_writeunique_seq[i].use_burst_incr = 1;
     axi_master_writeunique_seq[i].m_axlen= axlen;
     axi_master_writeunique_seq[i].m_data_from_test = new[axlen+1];
     end  
     axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].m_axlen=((SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA) -1; // overwrite flag data cache line only
     axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].m_data_from_test = new[(SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA];

    // SETUP READ SEQ = FLAG
    axi_rdonce_seq<%=ncidx%>   = ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq::type_id::create("axi_rdonce_seq<%=ncidx%>");
    axi_rdonce_seq<%=ncidx%>.m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioidx%>[0]; 
    axi_rdonce_seq<%=ncidx%>.m_len = ((SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA)-1; // cacheline size / axi data width
    axi_rdonce_seq<%=ncidx%>.use_arid = 0;
    axi_rdonce_seq<%=ncidx%>.m_addr = flag_addrq[producer_ncaiu[<%=ncidx%>]][0];

    `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("STARTED with data_addr=[start:%0h,end:%0h,size:%0d]  flag_addr=%0h",data_addrq[producer_ncaiu[<%=ncidx%>]][0],data_addrq[producer_ncaiu[<%=ncidx%>]][$], data_addrq[producer_ncaiu[<%=ncidx%>]].size(),flag_addrq[producer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
    `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("Number of cacheline send by txn:%0d with awlen=%0d wxdata=awsize=%0dbits",nbr_cacheline_by_txn,axlen,ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA), UVM_NONE)

     if (this.init[producer_ncaiu[<%=ncidx%>]]) begin // write flag 0
         axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].m_addr_from_test = ioaiu<%=ioidx%>_axi_agent_pkg::axi_axaddr_t'(flag_addrq[producer_ncaiu[<%=ncidx%>]][0]);
         axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].m_data_from_test[0] = 'h0;
         `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("Write init flag: write 0 at @%0h ",flag_addrq[producer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
         axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].start(ioaiu_vseqr<%=ioidx%>);
         this.init[producer_ncaiu[<%=ncidx%>]]=0;             
     end
     repeat (prod_consu_iter) begin:_repeat_iter
        iteration++;
        `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("Iteration %0d/%0d ",iteration,prod_consu_iter), UVM_NONE)
        repeat (test_cfg.ioaiu_num_trans*10*nbr_cacheline_by_txn) begin:_read_flag_loop 
             // read & check data=0
             `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("Read & check if flag= 0 at @%0h ",flag_addrq[producer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
             axi_rdonce_seq<%=ncidx%>.start(ioaiu_vseqr<%=ioidx%>);
             rresp =  axi_rdonce_seq<%=ncidx%>.m_seq_item.m_read_data_pkt.rresp;
             if (rresp) // != 0 => != OKAY
                `uvm_error("Producer ncaiu<%=ncidx%>",$sformatf("something wrong when read data @:%0h rresp=%0d",rresp,flag_addrq[producer_ncaiu[<%=ncidx%>]][0]))
             for (int i=0; i < axlen+1; i++) 
                 rdata[i] = axi_rdonce_seq<%=ncidx%>.m_seq_item.m_read_data_pkt.rdata[i];
             if (rdata[0] == 'h0) break; // if flag=0 (consumer finished)
          end:_read_flag_loop
      if (rdata[0]=='h1) // if flag = 1 (consumer not yet finish)
           `uvm_error("Producer ncaiu<%=ncidx%>",$sformatf("TIMEOUT Producer read flag %0dtime without success",test_cfg.ioaiu_num_trans*10*nbr_cacheline_by_txn))

     `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("flag= 0 at @%0h => START WRITE DATA ",flag_addrq[producer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
     for (int i=0; i < test_cfg.ioaiu_num_trans; i++ ) begin:_foreach_txn
         automatic int v_axlen = axlen;
         automatic int var_i = i;
         automatic int iter = iteration;
         automatic ioaiu<%=ioidx%>_axi_agent_pkg::axi_axaddr_t data_addr = ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t'(data_addrq[producer_ncaiu[<%=ncidx%>]][var_i*nbr_cacheline_by_txn]);
         automatic bit [(SYS_nSysCacheline*8) -1:0] cachedata[];
         automatic int nbr_wxdata_by_cacheline = (SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA;
         automatic int nbr_data_by_cacheline = (SYS_nSysCacheline*8)/DATA_SIZE;
       fork
         begin 
          cachedata=new[nbr_cacheline_by_txn];
          // fill cachedata
          for (int p=0; p<nbr_cacheline_by_txn;p++) begin:_foreach_cacheline_by_txn
              for (int d=0; d<nbr_data_by_cacheline;d++) begin:_foreach_data
                cachedata[p][d*DATA_SIZE+:DATA_SIZE] = data_addrq[producer_ncaiu[<%=ncidx%>]][p+(var_i*nbr_cacheline_by_txn)]+iter+(d*16); // ref data = cacheline adress + iteration index + (data index*16) 
              end:_foreach_data
          end:_foreach_cacheline_by_txn
          // send cachedata
          axi_master_writeunique_seq[var_i].m_addr_from_test = data_addr;
          for(int x=0;x< v_axlen+1;x=x+nbr_wxdata_by_cacheline) begin:_foreach_axlen 
            for (int j=0; j<nbr_wxdata_by_cacheline;j++) begin:_foreach_wxdata
              axi_master_writeunique_seq[var_i].m_data_from_test[x+j] = cachedata[x/nbr_wxdata_by_cacheline][j*ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA+:ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA];
              //$display("CLUDEBUG v_axlen:%d x:%0d j:%0d cachedata:%0h",v_axlen,x,j,axi_master_writeunique_seq[var_i].m_data_from_test[x+j]);
            end:_foreach_wxdata
             `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("wr_seq%0d Writing cachedata[%0d] @%0h data=%0h ",var_i,x/nbr_wxdata_by_cacheline,data_addr+ ((x/nbr_wxdata_by_cacheline)*(1<< <%=obj.wCacheLineOffset%>)),cachedata[x/nbr_wxdata_by_cacheline]), UVM_NONE)
          end:_foreach_axlen
          axi_master_writeunique_seq[var_i].start(ioaiu_vseqr<%=ioidx%>);
         end
       join_none 
     end:_foreach_txn

       begin:_write_flag
         automatic ioaiu<%=ioidx%>_axi_agent_pkg::axi_axaddr_t flag_addr = ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t'(flag_addrq[producer_ncaiu[<%=ncidx%>]][0]);
         automatic bit [(SYS_nSysCacheline*8) -1:0] flagdata= 'h1;
        fork// fork the last write to be sure that the write of the flag is done after the last data write
         begin 
         axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].m_addr_from_test = flag_addr;
          for(int x=0;x< (SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA;x++)  
             axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].m_data_from_test[x] = flagdata[x*ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA+:ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA];
         `uvm_info("Producer ncaiu<%=ncidx%>", $sformatf("Write flag: write 1 at @%0h ",flag_addr), UVM_NONE)
         axi_master_writeunique_seq[test_cfg.ioaiu_num_trans].start(ioaiu_vseqr<%=ioidx%>);  
         end
        join_none
       end:_write_flag
    `uvm_info("Producer ncaiu<%=ncidx%>","WAIT...", UVM_NONE);
     wait fork;
     end:_repeat_iter 
    `uvm_info("Producer ncaiu<%=ncidx%>","FINISHED", UVM_NONE);
endtask:producer_ncaiu<%=ncidx%>

task concerto_fullsys_pcie_prod_consu_test::consumer_ncaiu<%=ncidx%>();
     // TASK : 
     //   CONSUMER PRODUCER IOAIU if read flag=1  repeat (test_cfg.ioaiu_num_trans) read addr:data_addr[!!!end!!! .. start] data:addr + iter_idx  END write flag=0
     int iteration=0;
     int axlen=((axlenB*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA)-1;// ex: 256Bytes*8 / 128bits = axlen
     /// !!! Don't use MPU => coreid=0 !!!
     ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_master_writeunique_seq axi_master_writeunique_seq;
     bit [ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA-1:0] rdata[(SYS_nSysCacheline*8)/ ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA]; 
     ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq axi_rdonce_seq<%=ncidx%>[int];
     ioaiu<%=ioidx%>_axi_agent_pkg::axi_rresp_t rresp;
     // SETUP WRITE SEQ
     axi_master_writeunique_seq = ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_master_writeunique_seq::type_id::create("axi_master_writeunique_seq");
     axi_master_writeunique_seq.m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_axi_master_agent.m_write_addr_chnl_seqr;
     axi_master_writeunique_seq.m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_axi_master_agent.m_write_data_chnl_seqr;
     axi_master_writeunique_seq.m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_axi_master_agent.m_write_resp_chnl_seqr;
     axi_master_writeunique_seq.m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioidx%>[0]; 
     // COMMMON SETUP:
     axi_master_writeunique_seq.get_addr_from_test = 1;
     axi_master_writeunique_seq.get_data_from_test = 1;
     axi_master_writeunique_seq.k_num_write_req = 1;
     axi_master_writeunique_seq.use_burst_incr = 1;
     axi_master_writeunique_seq.m_data_from_test = new[(SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA];

    // SETUP READ SEQ
    for (int i=0; i<test_cfg.ioaiu_num_trans+1;i++) begin  // !!!!!!!!!!num_trans +1 =>  read:   data[0 ... num_trans-1] + flag  !!!!!!
        axi_rdonce_seq<%=ncidx%>[i]   = ioaiu<%=ioidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq::type_id::create(($sformatf("axi_rdonce_seq<%=ncidx%>_%0d",i)));
        axi_rdonce_seq<%=ncidx%>[i].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioidx%>[0]; 
        axi_rdonce_seq<%=ncidx%>[i].m_len = axlen; // cacheline size/ axi data width
        axi_rdonce_seq<%=ncidx%>[i].use_arid = 0;
    end 
        axi_rdonce_seq<%=ncidx%>[test_cfg.ioaiu_num_trans].m_len = ((SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA)-1; //overwrite  read flag only cacheline size 

    `uvm_info("Consumer ncaiu<%=ncidx%>", $sformatf("STARTED with data_addr=[start:%0h,end:%0h,size:%0d]  flag_addr=%0h",data_addrq[consumer_ncaiu[<%=ncidx%>]][0],data_addrq[consumer_ncaiu[<%=ncidx%>]][$], data_addrq[consumer_ncaiu[<%=ncidx%>]].size(),flag_addrq[consumer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
    `uvm_info("Consumer ncaiu<%=ncidx%>", $sformatf("Number of cacheline read by txn:%0d with arlen=%0d wxdata=arsize:%0dbits",nbr_cacheline_by_txn,axlen,ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA), UVM_NONE)
     wait(this.init[consumer_ncaiu[<%=ncidx%>]] ==0); // wait init finished
     repeat (prod_consu_iter) begin:_repeat_iter
          iteration++;
          `uvm_info("Consumer ncaiu<%=ncidx%>", $sformatf("Iteration %0d/%0d ",iteration,prod_consu_iter), UVM_NONE)
          repeat (test_cfg.ioaiu_num_trans*10*nbr_cacheline_by_txn) begin:_read_flag_loop 
             // read & check data=0
             `uvm_info("Consumer ncaiu<%=ncidx%>", $sformatf("Read & check if flag= 1 at @%0h ",flag_addrq[consumer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
             axi_rdonce_seq<%=ncidx%>[test_cfg.ioaiu_num_trans].m_addr = flag_addrq[consumer_ncaiu[<%=ncidx%>]][0];
             axi_rdonce_seq<%=ncidx%>[test_cfg.ioaiu_num_trans].start(ioaiu_vseqr<%=ioidx%>);
             rresp =  axi_rdonce_seq<%=ncidx%>[test_cfg.ioaiu_num_trans].m_seq_item.m_read_data_pkt.rresp;
             if (rresp) // != 0 => != OKAY
                `uvm_error("Consumer ncaiu<%=ncidx%>",$sformatf("something wrong when read data @:%0h rresp=%0d",rresp,flag_addrq[consumer_ncaiu[<%=ncidx%>]][0]))
             for (int i=0; i < axlen+1; i++) 
                 rdata[i] = axi_rdonce_seq<%=ncidx%>[test_cfg.ioaiu_num_trans].m_seq_item.m_read_data_pkt.rdata[i];
             if (rdata[0]=='h1) break; // if flag=1 (producer finished)
          end:_read_flag_loop
      if (rdata[0] ==0) // if flag = 0 (producer not yet finish)
           `uvm_error("Consumer ncaiu<%=ncidx%>",$sformatf("TIMEOUT Consumer read flag %0dtime without success",test_cfg.ioaiu_num_trans*10*nbr_cacheline_by_txn))

      `uvm_info("Consumer ncaiu<%=ncidx%>", $sformatf("flag= 1 at @%0h => START READ DATA ",flag_addrq[consumer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
      for (int i=test_cfg.ioaiu_num_trans-1; i>=0;i--)begin:_foreach_addr  // !!!!!!!!!! use revert data_addrq  to check that the last data has been written before write of the flag !!!!!!
         automatic int v_axlen = axlen;
         automatic int var_i = i;
         automatic int iter = iteration;
         automatic int index_of_data_addrq = var_i*nbr_cacheline_by_txn; // index = final address - nbr cacheline send in a burst  
         automatic bit [ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA-1:0] rdata[]; 
         automatic ioaiu<%=ioidx%>_axi_agent_pkg::axi_axaddr_t data_addr = ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t'(data_addrq[consumer_ncaiu[<%=ncidx%>]][index_of_data_addrq]);
         automatic bit [(SYS_nSysCacheline*8) -1:0] cachedata_exp[];
         automatic bit [(SYS_nSysCacheline*8) -1:0] cachedata_recv[];
         automatic int nbr_wxdata_by_cacheline = (SYS_nSysCacheline*8)/ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA;
         automatic int nbr_data_by_cacheline = (SYS_nSysCacheline*8)/DATA_SIZE;
       fork
         begin 
          axi_rdonce_seq<%=ncidx%>[var_i].m_addr = data_addr;
          axi_rdonce_seq<%=ncidx%>[var_i].start(ioaiu_vseqr<%=ioidx%>);
          rresp =  axi_rdonce_seq<%=ncidx%>[var_i].m_seq_item.m_read_data_pkt.rresp;
          rdata = new[v_axlen+1];
          cachedata_exp = new[nbr_cacheline_by_txn];
          cachedata_recv = new[nbr_cacheline_by_txn];
          if (rresp) // != 0 => != OKAY
             `uvm_error("Consumer ncaiu<%=ncidx%>",$sformatf("something wrong when read data @:%0h rresp=%0d",data_addr,rresp))
          for (int p=0; p<nbr_cacheline_by_txn;p++) begin:_foreach_cacheline_by_txn
              for (int d=0; d<nbr_data_by_cacheline;d++) begin:_foreach_data
                  cachedata_exp[p][d*DATA_SIZE+:DATA_SIZE] = data_addrq[consumer_ncaiu[<%=ncidx%>]][p+index_of_data_addrq] +iter + (d*16);// data = cacheline adress + iteration index + (data index*16) 
              end:_foreach_data
          end:_foreach_cacheline_by_txn
         for (int x=0; x < v_axlen+1; x=x+nbr_wxdata_by_cacheline) begin:_foreach_axlen
            for (int j=0; j<nbr_wxdata_by_cacheline;j++) begin:_foreach_cacheline
             cachedata_recv[x/nbr_wxdata_by_cacheline][ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA*j+:ioaiu<%=ioidx%>_axi_agent_pkg::WXDATA] = axi_rdonce_seq<%=ncidx%>[var_i].m_seq_item.m_read_data_pkt.rdata[x+j];
             //$display("CLUDEBUG v_axlen:%0d x:%0d j:%0d cachedata:%0h",v_axlen,x,j,cachedata_recv[x/nbr_wxdata_by_cacheline]);
           end:_foreach_cacheline
         `uvm_info("Consumer ncaiu<%=ncidx%>", $sformatf("Read cacheline%0d data = %0h @%0h",x/nbr_wxdata_by_cacheline,cachedata_recv[x/nbr_wxdata_by_cacheline],data_addrq[consumer_ncaiu[<%=ncidx%>]][index_of_data_addrq]), UVM_NONE)
         if (cachedata_exp[x/nbr_wxdata_by_cacheline] != cachedata_recv[x/nbr_wxdata_by_cacheline])
           `uvm_error("Consumer ncaiu<%=ncidx%>",$sformatf("COMPARE cacheline:%0d exp:%0h recv:%0h",x/nbr_wxdata_by_cacheline,cachedata_exp[x/nbr_wxdata_by_cacheline],cachedata_recv[x/nbr_wxdata_by_cacheline]))
         end:_foreach_axlen
         end
       join 
     end:_foreach_addr
      begin 
      axi_master_writeunique_seq.m_addr_from_test =  ioaiu<%=ioidx%>_axi_agent_pkg::axi_axaddr_t'(flag_addrq[consumer_ncaiu[<%=ncidx%>]][0]);
      axi_master_writeunique_seq.m_data_from_test[0] = 'h0;
      `uvm_info("Consumer ncaiu<%=ncidx%>", $sformatf("Write flag: write 0 at @%0h ",flag_addrq[consumer_ncaiu[<%=ncidx%>]][0]), UVM_NONE)
      axi_master_writeunique_seq.start(ioaiu_vseqr<%=ioidx%>);  
      end
    `uvm_info("Consumer ncaiu<%=ncidx%>","WAIT...", UVM_NONE);
     wait fork;
     end:_repeat_iter 
    `uvm_info("Consumer ncaiu<%=ncidx%>","FINISHED", UVM_NONE);
endtask:consumer_ncaiu<%=ncidx%>
 <% ncidx++; ioidx++ }  // IF not CHI  %>
 <%if((obj.AiuInfo[idx].fnNativeInterface == "ACE")) { ioidx++;} %>
<%}%> // Foreach AIU