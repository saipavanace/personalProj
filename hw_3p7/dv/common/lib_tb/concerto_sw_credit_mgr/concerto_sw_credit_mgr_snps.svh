////////////////////////////////////////////////////////////
//                                                        //
//Description: provides credits number to each AIU        //
//             agents.                                    //
//                                                        //
//File:        concerto_sw_credit_mgr_pkg.sv              //
//                                                        //
////////////////////////////////////////////////////////////
<%

var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numIoAiu_mpu =0;//Number of IO AIUS including mpu cores
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var found_csr_access_ioaiu =0;
var found_csr_access_chi =0;
var csrAccess_ioaiu;
var csrAccess_chiaiu;

var qidx = 0;
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var numAiuRpns = 0;   //Total AIU RPN's
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var _blkid = [];
var _blktype = [];
var _blksuffix = [];
var _blk   = [];
var pidx = 0;
var ridx = 0;
var chiaiu_idx = 0;
var ioaiu_idx = 0;

for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       _blk[pidx]   = obj.AiuInfo[pidx];
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'ioaiu';
       ioaiu_idx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _blkid[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DceInfo[pidx];
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _blkid[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _blkid[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   
   var nALLs = ridx+1; 

for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
   } else {
       aiu_NumCores[pidx]    = 1;
   }
 }




for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if( obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-C" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-D" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")
    {
    // CLU TMP COMPILE FIX CONC-11383    if ((found_csr_access_chi==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_chi_idx = numChiAiu;
            csrAccess_chiaiu = numChiAiu;
            found_csr_access_chi = 1;
    //        }
        if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
        numChiAiu = numChiAiu + 1;numCAiu++ ; 
    } else {
      
    // CLU TMP COMPILE FIX CONC-11383    if ((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_io_idx = numIoAiu;
            csrAccess_ioaiu = numIoAiu;
            found_csr_access_ioaiu = 1;
    //        }
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       numIoAiu_mpu    += obj.AiuInfo[pidx].interfaces.axiInt.length;
    } else {
       numIoAiu_mpu++;
    }            
        numIoAiu = numIoAiu + 1;

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
    }
  if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}

var regPrefixName = function() {
                                if (obj.BlockId.charAt(0)=="d")
                                    {return obj.BlockId.match(/[a-z]+/i)[0].toUpperCase();} //dmi,dii,dce,dve => DMI,DII,DVE 
                                if ((obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-A')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-B')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-E')) 
                                    {return "CAIU";}
                                return "XAIU"; // by default
                                };
%>

<%function generateRegPath(regName) {
    if(obj.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.strRtlNamePrefix+'_0.'+regName;
    } else {
        return 'm_regs.'+obj.strRtlNamePrefix+'.'+regName;
    }
}%>



`ifdef USE_VIP_SNPS // Now using this file for synopsys vip sim
import uvm_pkg::*;



class concerto_sw_credit_mgr extends uvm_object;

`uvm_object_param_utils(concerto_sw_credit_mgr)

parameter VALID_MAX_CREDIT_VALUE = 31;
int act_cmd_skid_buf_size[string][];//array to hold act. values of skid buffer size of each DMI/DCE/DII. act_cmd_skid_buf_size[DMI/DCE/DII][skid_buf_size] 
int act_mrd_skid_buf_size[string][];
int act_cmd_skid_buf_arb[string][];//array to hold act. values of skid buffer arb of each DMI/DCE/DII. act_cmd_skid_buf_arb[DMI/DCE/DII][skid_buf_size] 
int act_mrd_skid_buf_arb[string][];
int exp_cmd_skid_buf_size[string][];//array to hold act. values of skid buffer size of each DMI/DCE/DII. exp_cmd_skid_buf_size[DMI/DCE/DII][skid_buf_size] 
int exp_mrd_skid_buf_size[string][];
int exp_cmd_skid_buf_arb[string][];//array to hold act. values of skid buffer arb of each DMI/DCE/DII. exp_cmd_skid_buf_arb[DMI/DCE/DII][skid_buf_size] 
int exp_mrd_skid_buf_arb[string][];
int temp_dii_buf_size;
bit en_credit_alloc =1;//TODO dont forget should be 1
//set env 
concerto_env_pkg::concerto_env_cfg m_concerto_env_cfg;  
concerto_env_pkg::concerto_env     m_concerto_env;
//set credit variable
concerto_env_pkg::concerto_env_cfg::t_aCredit aCredit_Cmd;
concerto_env_pkg::concerto_env_cfg::t_aCredit aCredit_Mrd;

// plusarg management
string     chiaiu_en_str[];
string     ioaiu_en_str[];
string     chiaiu_en_arg;
string     ioaiu_en_arg;
bit [<%=numChiAiu%>-1:0]t_chiaiu_en;
bit [<%=numIoAiu%>-1:0]t_ioaiu_en;
int chiaiu_en[int];
int ioaiu_en[int];

// some info from JSON
int numChiAiu=<%=numChiAiu%>;
int numIoAiu=<%=numIoAiu%>;
int active_numChiAiu=0;
int active_numIoAiu=0;
int numCmdCCR;
int numMrdCCR;
// System Census 
bit [7:0] nAIUs; // Max 128
bit [5:0] nDCEs; // Max 32
bit [5:0] nDMIs; // Max 32
bit [5:0] nDIIs; // Max 32 or nDIIs
bit       nDVEs; // Max 1
string block[3];

//boot selection 
bit t_boot_from_ioaiu=1;
//rpn page selection 
bit [7:0] rpn;
bit [7:0] cur_rpn;
//connectivity check 
bit en_connectivity_cmd_check;
bit en_connectivity_mrd_check;
svt_amba_env_class_pkg::svt_amba_env   concerto_svt_env;

//constructor
  extern function new(string s = "concerto_sw_credit_mgr");
  extern virtual function void build_phase(uvm_phase  phase);
//functions
  extern function uvm_reg_data_t mask_data(int lsb, int msb);
  extern function void parse_str(output string out[], input byte separator, input string in);
  extern function void credit_alloc(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);//this function compute the amount of credit to allocate to each aiu
  extern function void credit_printer(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);//this function compute the amount of credit to allocate to each aiu
  extern function void set_crdt_cfg();// function to get concerto_env.cfg.tCreditXXX must be by DB
  extern function void get_crdt_cfg(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);// function to get concerto_env.cfg.tCreditXXX must be by DB
  <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
// CLU TMP COMPILE FIX CONC-11383     if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  extern  task boot_sw_crdt<%=qidx%>();
    // fucntion to overwrite credit 
  extern task overwrite_credit<%=qidx%>(int credit);
  `ifdef VCS
  extern task check_csr<%=qidx%>();//this function will check skid buffer size 
  `else
  extern function void check_csr<%=qidx%>();//this function will check skid buffer size 
  `endif
  extern task set_csr_crdt<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);// function to get concerto_env.cfg.tCreditXXX must be by DB
  extern function void crdt_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);// this function adapt credit format from fsys to block format and update block SB 
  extern function void crdt_ioaiu_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
  extern task read_csr_<%=qidx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);
  extern task write_csr_<%=qidx%>(uvm_reg_field field, uvm_reg_data_t wr_data);
  extern task write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data);
  extern task read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0]data);
  ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[idx]%>];

    <% //} 
    qidx++; }
    } %>
  
  bit en_rw_csr_from_ioaiu=1'b1;    

  uvm_domain       m_concerto_domain;
<% if ( numChiAiu > 0){ %>
        chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=csrAccess_chi_idx%>)   m_chi_csr_vseq;
 <% } %> 
     
endclass: concerto_sw_credit_mgr



function concerto_sw_credit_mgr::new(string s = "concerto_sw_credit_mgr");
  super.new(s);


endfunction: new

function void concerto_sw_credit_mgr::build_phase(uvm_phase phase);
    if(!(uvm_config_db#(svt_amba_env_class_pkg::svt_amba_env)::get(uvm_root::get(), "", "concerto_svt_env", concerto_svt_env)))begin
        `uvm_fatal("concerto_sw_credit_mgr", "concerto_svt_env not found through config db");
    end
endfunction : build_phase

function void concerto_sw_credit_mgr::set_crdt_cfg();
uvm_config_db#(concerto_env_pkg::concerto_env_cfg::t_aCredit)::set(null,"concerto_env_pkg::concerto_env_cfg","aCredit_Cmd", aCredit_Cmd);
uvm_config_db#(concerto_env_pkg::concerto_env_cfg::t_aCredit)::set(null,"concerto_env_pkg::concerto_env_cfg","aCredit_Mrd", aCredit_Mrd);

endfunction: set_crdt_cfg

function void concerto_sw_credit_mgr::get_crdt_cfg(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);


     foreach(AiuIds[i]) begin
           foreach(DceIds[j]) begin 
            aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]] = m_concerto_env_cfg.aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]];
          end
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]] = m_concerto_env_cfg.aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]];
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]] = m_concerto_env_cfg.aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]];
          end                  
    end 
    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin
        aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]= m_concerto_env_cfg.aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]];
      end
    end

endfunction: get_crdt_cfg



 <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
// CLU TMP COMPILE FIX CONC-11383     if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
task concerto_sw_credit_mgr::overwrite_credit<%=qidx%>(int credit);
bit [31:0] data;
string temp_string="";
uvm_reg_data_t fieldVal;
int aiu_NumCores[int];
int j;
int cnt_core;
ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;	

addr = addr_trans_mgr_pkg::addrMgrConst::NRS_REGION_BASE ;
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
      for(int x=0;x<numCmdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCR0.get_offset()<%}%>;
        addr[11:0] = addr[11:0] + (x*4);
        //read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("set_credit sw_credit_mgr", $sformatf("overwriting credit by %0d credit ",credit), UVM_LOW)
        data[4:0]   = credit;
        data[12:8]  = credit;
        data[20:16] = credit;
        data[31:24] = 8'hE0;
        write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
      end
      rpn++;

    end // for (int i=0; i<nAIUs; i++)		
endtask: overwrite_credit<%=qidx%>

function void concerto_sw_credit_mgr::crdt_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
//
string dce_credit_msg="";
int new_dce_credits;

//concerto_sw_credit_mgr::get_crdt_cfg();


<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      for(int x=0;x<numMrdCCR;x++) begin
        $sformat(dce_credit_msg, "dce%0d_dmi%0d_nMrdInFlight", DceIds[<%=pidx%>], DmiIds[x]);
        //new_dce_credits=m_concerto_env_cfg.aCredit_Mrd[DceIds[<%=pidx%>]]["DMI"][DmiIds[x]];
        new_dce_credits=aCredit_Mrd[DceIds[<%=pidx%>]]["DMI"][DmiIds[x]];
        if(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.has_scoreboard)begin
          m_concerto_env.m_dce<%=pidx%>_env.m_dce_scb.m_credits.scm_credit(dce_credit_msg, new_dce_credits);
        end
      end
<% } %>

// call ioaiu adapter
  if($test$plusargs("scm_use_ioaiu_adapter")) begin
    concerto_sw_credit_mgr::crdt_ioaiu_adapter<%=qidx%>(AiuIds,DmiIds,DceIds,DiiIds);
  end
endfunction: crdt_adapter<%=qidx%>

function void concerto_sw_credit_mgr::crdt_ioaiu_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
//

//concerto_sw_credit_mgr::get_crdt_cfg();
  <% for(var ioaiu_idx = 0, pidx = 0 ; pidx < obj.nAIUs; pidx++) { 
     if(!((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')|| (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'))) { 
      for(var core_idx=0; core_idx<aiu_NumCores[pidx]; core_idx++) { %>
        foreach(DceIds[j]) begin 
          if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
            m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].dceCreditLimit[DceIds[j]]=int'(aCredit_Cmd[AiuIds[<%=ioaiu_idx%>]]["DCE"][DceIds[j]]);
          end 
        end
    

        foreach(DmiIds[k]) begin          
          if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
            m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].dmiCreditLimit[DmiIds[k]]=int'(aCredit_Cmd[AiuIds[<%=ioaiu_idx%>]]["DMI"][DmiIds[k]]);
          end
        end

       foreach(DiiIds[p]) begin 
        if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
          m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].diiCreditLimit[DiiIds[p]]=int'(aCredit_Cmd[AiuIds[<%=ioaiu_idx%>]]["DII"][DiiIds[p]]);
        end
       end
<% } 
 ioaiu_idx++; }
 } %> 




endfunction: crdt_ioaiu_adapter<%=qidx%>




task concerto_sw_credit_mgr::set_csr_crdt<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
///
bit [31:0] data;
string temp_string="";
uvm_reg_data_t fieldVal;
int aiu_NumCores[int];
int j;
int cnt_core;
ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;	

<%for(pidx = 0; pidx < obj.nAIUs; pidx++) {%>
  aiu_NumCores[<%=pidx%>] =  <%=aiu_NumCores[pidx]%> ;
<%}%>
addr = addr_trans_mgr_pkg::addrMgrConst::NRS_REGION_BASE ;
    rpn = 0; //chi_rpn;
    j =0;
    cnt_core=1;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
      for(int x=0;x<numCmdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCR0.get_offset()<%}%>;
        addr[11:0] = addr[11:0] + (x*4);
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("programming credit aCredit_Cmd[%0d][DCE][%0d] = %0d ",i, DceIds[x], aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]), UVM_MEDIUM)
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("programming credit aCredit_Cmd[%0d][DMI][%0d] = %0d ",i, DmiIds[x], aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[x]]), UVM_MEDIUM)
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("programming credit aCredit_Cmd[%0d][DII][%0d] = %0d ",i, DiiIds[x], aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[x]]), UVM_MEDIUM)
        data[4:0]   = aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]];
        data[12:8]  = aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[x]];
        data[20:16] = aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[x]];
        data[31:24] = 8'hE0;
        write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Writing rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        //check nonconnected register field 
        //#Check.FSYS.RDCCRstate.noconnection
        if (en_connectivity_cmd_check) begin 
          if (aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] == 0 && data[7:5] != 7) begin 
            `uvm_error("set_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DCE with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be 7 No Connection ",DceIds[x],AiuIds[i],data[7:5]))
          end
          if (aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[x]] == 0 && data[15:13] != 7) begin 
            `uvm_error("set_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DMI with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be 7 No Connection ",DmiIds[x],AiuIds[i],data[15:13]))
          end  
          if (aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[x]] == 0 && data[23:21] != 7) begin 
            `uvm_error("set_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DII with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be 7 No Connection ",DmiIds[x],AiuIds[i],data[23:21]))
          end   
        end    
      end
      rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    cur_rpn = rpn; ;
    for(int i=0; i< <%=obj.nDCEs%>; i++) begin
      for(int x=0;x<numMrdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] =  m_concerto_env.m_regs.dce0.DCEUCCR0.get_offset();
        addr[11:0] = addr[11:0] + (x*4);
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        data[4:0]   = aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[x]];
        data[15:8]  = 8'hE0;
        data[23:16] = 8'hE0;
        data[31:24] = 8'hE0;
        write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Writing rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
      end
      rpn++;
    end // for (int i=0; i<nDCEs; i++)	
    //concerto_sw_credit_mgr::set_crdt_cfg();
endtask: set_csr_crdt<%=qidx%>

`ifdef VCS
task concerto_sw_credit_mgr::check_csr<%=qidx%>();
`else
function void concerto_sw_credit_mgr::check_csr<%=qidx%>();
`endif
int AiuIds[];
int DceIds[];
int DmiIds[];
int DiiIds[];
bit [7:0] nAIUs; // Max 128
bit [5:0] nDCEs; // Max 32
bit [5:0] nDMIs; // Max 32
bit [5:0] nDIIs; // Max 32 or nDIIs
bit       nDVEs; // Max 1
string block[3];
int aiu_indx = 0;
int dce_indx = 0;
int dmi_indx = 0;
int dii_indx = 0;
//reg variables      
uvm_reg_data_t fieldVal;
bit [31:0] data;

`ifdef VCS
block = '{"DCE", "DMI", "DII"};
`else
block[3] = '{"DCE", "DMI", "DII"};
`endif

for (int i = 0 ; i < $size(block); i++) begin
  act_cmd_skid_buf_size[block[i]]=new[1];
  act_cmd_skid_buf_size[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
  act_cmd_skid_buf_arb[block[i]]=new[1];
  act_cmd_skid_buf_arb[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
  exp_cmd_skid_buf_size[block[i]]=new[1];
  exp_cmd_skid_buf_size[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
  exp_cmd_skid_buf_arb[block[i]]=new[1];
  exp_cmd_skid_buf_arb[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
  if (block[i]=="DMI") begin
   act_mrd_skid_buf_size[block[i]] = new[1];
   act_mrd_skid_buf_size[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
   act_mrd_skid_buf_arb[block[i]] = new[1];
   act_mrd_skid_buf_arb[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
   exp_mrd_skid_buf_size[block[i]] = new[1];
   exp_mrd_skid_buf_size[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
   exp_mrd_skid_buf_arb[block[i]] = new[1];
   exp_mrd_skid_buf_arb[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
      
  end

end

  
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nAIUs"), fieldVal);//data[ 7: 0];
  nAIUs = int'(fieldVal);
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDCEs"), fieldVal);//data[ 7: 0];
  nDCEs = int'(fieldVal);
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDMIs"), fieldVal);//data[ 7: 0];
  nDMIs = int'(fieldVal);
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDPIs"), fieldVal);//data[ 7: 0];
  nDIIs = int'(fieldVal);
  `uvm_info("check_csr",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDIIs:%0d",nAIUs,nDCEs,nDMIs,nDIIs),UVM_NONE)

if(nDCEs>0) begin
      act_cmd_skid_buf_size["DCE"] = new[nDCEs];
      act_cmd_skid_buf_arb["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_size["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_arb["DCE"] = new[nDCEs];
    end

    if(nDMIs>0) begin
      act_cmd_skid_buf_size["DMI"] = new[nDMIs];
      act_mrd_skid_buf_size["DMI"] = new[nDMIs];
      act_cmd_skid_buf_arb["DMI"] = new[nDMIs];
      act_mrd_skid_buf_arb["DMI"] = new[nDMIs];
      exp_cmd_skid_buf_size["DMI"] = new[nDMIs];
      exp_mrd_skid_buf_size["DMI"] = new[nDMIs];
      exp_cmd_skid_buf_arb["DMI"] = new[nDMIs];
      exp_mrd_skid_buf_arb["DMI"] = new[nDMIs];
    end

    if(nDIIs>0) begin
      act_cmd_skid_buf_size["DII"] = new[nDIIs];
      act_cmd_skid_buf_arb["DII"] = new[nDIIs];
      exp_cmd_skid_buf_size["DII"] = new[nDIIs];
      exp_cmd_skid_buf_arb["DII"] = new[nDIIs];
    end

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDCEs; tempidx++) {%>
      exp_cmd_skid_buf_size["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DCE"][<%=tempidx%>]  = <%=obj.DceInfo[tempidx].nCMDSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDMIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DMI"][<%=tempidx%>]  = <%=obj.DmiInfo[tempidx].nCMDSkidBufArb%>;
      exp_mrd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufSize%>;
      exp_mrd_skid_buf_arb["DMI"][<%=tempidx%>]  = <%=obj.DmiInfo[tempidx].nMrdSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDIIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DII"][<%=tempidx%>]  = <%=obj.DiiInfo[tempidx].nCMDSkidBufArb%>;
<%}%>
//DCE skid buf size check 
<% for(var pidx_dce = 0; pidx_dce < obj.nDCEs; pidx_dce++) { %>
  dce_indx=<%=pidx_dce%>;
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.DCEUSBSIR.get_field_by_name("SkidBufArb"), fieldVal);
  act_cmd_skid_buf_arb["DCE"][dce_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DCE REG] Reading  DCEUSBSIR SkidBufArb:act_cmd_skid_buf_arb[DCE][%0d]=%0d ",dce_indx,act_cmd_skid_buf_arb["DCE"][dce_indx]), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.DCEUSBSIR.get_field_by_name("SkidBufSize"), fieldVal);
  act_cmd_skid_buf_size["DCE"][dce_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DCE REG] Reading  DCEUSBSIR SkidBufSize:act_cmd_skid_buf_size[DCE][%0d]=%0d ",dce_indx,act_cmd_skid_buf_size["DCE"][dce_indx]), UVM_LOW)
<%}%>

    if(exp_cmd_skid_buf_size["DCE"].size != act_cmd_skid_buf_size["DCE"].size) begin
        `uvm_error("check_csr sw_credit_mgr",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE].size %0d != act_cmd_skid_buf_size[DCE].size %0d",exp_cmd_skid_buf_size["DCE"].size,act_cmd_skid_buf_size["DCE"].size))
    end
    foreach(exp_cmd_skid_buf_size["DCE"][temp]) begin
        if(exp_cmd_skid_buf_size["DCE"][temp]!= act_cmd_skid_buf_size["DCE"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE][%0d] %0d != act_cmd_skid_buf_size[DCE][%0d] %0d",temp,exp_cmd_skid_buf_size["DCE"][temp],temp,act_cmd_skid_buf_size["DCE"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DCE"][temp]!= act_cmd_skid_buf_arb["DCE"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DCE] exp_cmd_skid_buf_arb[DCE][%0d] %0d != act_cmd_skid_buf_arb[DCE][%0d] %0d",temp,exp_cmd_skid_buf_arb["DCE"][temp],temp,act_cmd_skid_buf_arb["DCE"][temp]))
        end
    end
//DMI skid buf chekc
<% for(var pidx_dmi = 0; pidx_dmi < obj.nDMIs; pidx_dmi++) { %>
      dmi_indx=<%=pidx_dmi%>;
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("MRDSBSIR").get_field_by_name("SkidBufArb"), fieldVal);
  act_mrd_skid_buf_arb["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  MRDSBSIR act_mrd_skid_buf_arb[DMI][%0d]=%0d ",dmi_indx,act_mrd_skid_buf_arb["DMI"][dmi_indx]), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("MRDSBSIR").get_field_by_name("SkidBufSize"), fieldVal);
  act_mrd_skid_buf_size["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  MRDSBSIR SkidBufSize:act_mrd_skid_buf_size[DMI][%0d]=%0d ",dmi_indx,act_mrd_skid_buf_size["DMI"][dmi_indx]), UVM_LOW)

  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("CMDSBSIR").get_field_by_name("SkidBufArb"), fieldVal);
  act_cmd_skid_buf_arb["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  CMDSBSIR act_cmd_skid_buf_arb[DMI][%0d]=%0d ",dmi_indx,act_cmd_skid_buf_arb["DMI"][dmi_indx]), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("CMDSBSIR").get_field_by_name("SkidBufSize"), fieldVal);
  act_cmd_skid_buf_size["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  CMDSBSIR SkidBufSize:act_cmd_skid_buf_size[DMI][%0d]=%0d ",dmi_indx,act_cmd_skid_buf_size["DMI"][dmi_indx]), UVM_LOW)
<%}%>
//check
  if(exp_cmd_skid_buf_size["DMI"].size != act_cmd_skid_buf_size["DMI"].size) begin
      `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI].size %0d != act_cmd_skid_buf_size[DMI].size %0d",exp_cmd_skid_buf_size["DMI"].size,act_cmd_skid_buf_size["DMI"].size))
  end
  foreach(exp_cmd_skid_buf_size["DMI"][temp]) begin
      if(exp_cmd_skid_buf_size["DMI"][temp]!= act_cmd_skid_buf_size["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI][%0d] %0d != act_cmd_skid_buf_size[DMI][%0d] %0d",temp,exp_cmd_skid_buf_size["DMI"][temp],temp,act_cmd_skid_buf_size["DMI"][temp]))
      end
      if(exp_cmd_skid_buf_arb["DMI"][temp]!= act_cmd_skid_buf_arb["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_cmd_skid_buf_arb[DMI][%0d] %0d != act_cmd_skid_buf_arb[DMI][%0d] %0d",temp,exp_cmd_skid_buf_arb["DMI"][temp],temp,act_cmd_skid_buf_arb["DMI"][temp]))
      end
  end
  if(exp_mrd_skid_buf_size["DMI"].size != act_mrd_skid_buf_size["DMI"].size) begin
      `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI].size %0d != act_mrd_skid_buf_size[DMI].size %0d",exp_mrd_skid_buf_size["DMI"].size,act_mrd_skid_buf_size["DMI"].size))
  end
  foreach(exp_mrd_skid_buf_size["DMI"][temp]) begin
      if(exp_mrd_skid_buf_size["DMI"][temp]!= act_mrd_skid_buf_size["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI][%0d] %0d != act_mrd_skid_buf_size[DMI][%0d] %0d",temp,exp_mrd_skid_buf_size["DMI"][temp],temp,act_mrd_skid_buf_size["DMI"][temp]))
      end
      if(exp_mrd_skid_buf_arb["DMI"][temp]!= act_mrd_skid_buf_arb["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_mrd_skid_buf_arb[DMI][%0d] %0d != act_mrd_skid_buf_arb[DMI][%0d] %0d",temp,exp_mrd_skid_buf_arb["DMI"][temp],temp,act_mrd_skid_buf_arb["DMI"][temp]))
      end
  end
//end //for(int i=0; i<nDMIs; i++)

<% for(var pidx_dii = 0; pidx_dii < obj.nDIIs; pidx_dii++) { %>
    //for(int i=0; i<nDIIs; i++) begin
      dii_indx=<%=pidx_dii%>;
 // read DII skiid buffer sizes
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUSBSIR").get_field_by_name("SkidBufSize"), fieldVal);
  act_cmd_skid_buf_size["DII"][dii_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DII REG] Reading  DIIUSBSIR SkidBufSize:act_cmd_skid_buf_size[DII][%0d]=%0d fieldVal = %0d",dii_indx,act_cmd_skid_buf_size["DII"][dii_indx],fieldVal), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUSBSIR").get_field_by_name("SkidBufArb"), fieldVal);
   act_cmd_skid_buf_arb["DII"][dii_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DII REG] Reading  DIIUSBSIR SkidBufArb:act_cmd_skid_buf_arb[DII][%0d]=%0d fieldVal = %0d",dii_indx,act_cmd_skid_buf_arb["DII"][dii_indx],fieldVal), UVM_LOW)

<%}%>
    if(exp_cmd_skid_buf_size["DII"].size != act_cmd_skid_buf_size["DII"].size) begin
        `uvm_error("check_csr sw_credit_mgr",$sformatf("[DII] exp_cmd_skid_buf_size[DII].size %0d != act_cmd_skid_buf_size[DII].size %0d",exp_cmd_skid_buf_size["DII"].size,act_cmd_skid_buf_size["DII"].size))
    end
    foreach(exp_cmd_skid_buf_size["DII"][temp]) begin
        if(exp_cmd_skid_buf_size["DII"][temp]!= act_cmd_skid_buf_size["DII"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DII] exp_cmd_skid_buf_size[DII][%0d] %0d != act_cmd_skid_buf_size[DII][%0d] %0d",temp,exp_cmd_skid_buf_size["DII"][temp],temp,act_cmd_skid_buf_size["DII"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DII"][temp]!= act_cmd_skid_buf_arb["DII"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DII] exp_cmd_skid_buf_arb[DII][%0d] %0d != act_cmd_skid_buf_arb[DII][%0d] %0d",temp,exp_cmd_skid_buf_arb["DII"][temp],temp,act_cmd_skid_buf_arb["DII"][temp]))
        end
    end
`ifdef VCS
endtask:check_csr<%=qidx%> 
`else
endfunction:check_csr<%=qidx%> 
`endif

task   concerto_sw_credit_mgr::boot_sw_crdt<%=qidx%>();
int AiuIds[];
int DceIds[];
int DmiIds[];
int DiiIds[];
bit [7:0] nAIUs; // Max 128
bit [5:0] nDCEs; // Max 32
bit [5:0] nDMIs; // Max 32
bit [5:0] nDIIs; // Max 32 or nDIIs
bit       nDVEs; // Max 1
string block[3];
int aiu_indx = 0;
int dce_indx = 0;
int dmi_indx = 0;
int dii_indx = 0;
//ral_sys_ncore       m_regs;
uvm_reg_data_t fieldVal;
bit [31:0] data;
string temp_string="";

  <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
 if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[<%=i%>]" ),.value( m_ioaiu_vseqr<%=qidx%>[<%=i%>] ) ))) begin
 `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>[<%=i%>]")
 end
      <%}%>
 `uvm_info("boot_sw_crdt", $sformatf("Start BOOT SW CREDIT"), UVM_LOW)
//concerto_sw_credit_mgr::set_crdt_cfg();
//concerto_sw_credit_mgr::get_crdt_cfg();
concerto_sw_credit_mgr::check_csr<%=qidx%>();


//AIUids DMI DCE DII ids compting

<% for(var pidx_aiu = 0; pidx_aiu < obj.nAIUs; pidx_aiu++) {%>
      //aiu_indx=<%=pidx_aiu%>;
      aiu_indx=0;
<% if((obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-E')){ %>
      <%if(Array.isArray(obj.AiuInfo[pidx_aiu].interfaces.axiInt)){%>
        <% for(var i=0; i<aiu_NumCores[pidx_aiu]; i++) { %> 
        read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>_<%=i%>.get_reg_by_name("XAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);  
       AiuIds = new[AiuIds.size()+1] (AiuIds);
       AiuIds[AiuIds.size()-1] =  int'(fieldVal); 
       aiu_indx++; 
        <% } %>// foreach cores
      <%} else {%>
        read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.get_reg_by_name("XAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);  
        AiuIds = new[AiuIds.size()+1] (AiuIds);
        AiuIds[AiuIds.size()-1] =  int'(fieldVal); 
        aiu_indx++;
      <%}%>
      <%} else {%>
       read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.get_reg_by_name("CAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
        AiuIds = new[AiuIds.size()+1] (AiuIds);
       AiuIds[AiuIds.size()-1] =  int'(fieldVal);
       aiu_indx++;
      <%}%>  
	    `uvm_info("boot_sw_crdt", $sformatf("Reg AIU_FUIDR-<%=pidx_aiu%> DATA 0x%0h", int'(fieldVal)), UVM_LOW)
      if(aiu_indx==0) begin temp_string=""; temp_string = $sformatf("%0s AiuIds : \n",temp_string); end
      temp_string = $sformatf("%0s %0d",temp_string,AiuIds[aiu_indx]);
 <% } %>

    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)

    <% for(var pidx_dce = 0; pidx_dce < obj.nDCEs; pidx_dce++) { %>
      dce_indx=<%=pidx_dce%>;
      read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.get_reg_by_name("DCEUFUIDR").get_field_by_name("FUnitId"), fieldVal);
	    `uvm_info("boot_sw_crdt", $sformatf("DCE_FUIDR-%0d  DATA 0x%0h",dce_indx,int'(fieldVal)), UVM_LOW)
        DceIds = new[DceIds.size()+1] (DceIds);
        DceIds[DceIds.size()-1] =  int'(fieldVal);
        if(dce_indx==0) begin temp_string=""; temp_string = $sformatf("%0s DceIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DceIds[dce_indx]);
 <% } %>			   
    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)
<% for(var pidx_dmi = 0; pidx_dmi < obj.nDMIs; pidx_dmi++) { %>
    //for(int i=0; i<nDMIs; i++) begin
      dmi_indx=<%=pidx_dmi%>;
      read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("DMIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
	    `uvm_info("boot_sw_crdt", $sformatf("DMI_FUIDR-%0d  DATA 0x%0h",dmi_indx,int'(fieldVal)), UVM_LOW)      
      DmiIds = new[DmiIds.size()+1] (DmiIds);
      DmiIds[DmiIds.size()-1] =  int'(fieldVal);
      if(dmi_indx==0) begin temp_string=""; temp_string = $sformatf("%0s DmiIds : \n",temp_string); end
      temp_string = $sformatf("%0s %0d",temp_string,DmiIds[dmi_indx]);
    //end // for (int i=0; i<nDMIs; i++)
    <% } %>				   
    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)
<% for(var pidx_dii = 0; pidx_dii < obj.nDIIs; pidx_dii++) { %>
    //for(int i=0; i<nDIIs; i++) begin
      dii_indx=<%=pidx_dii%>;
      read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
	    `uvm_info("boot_sw_crdt", $sformatf("DII_FUIDR-%0d  DATA 0x%0h",dii_indx,int'(fieldVal)), UVM_LOW)
        DiiIds = new[DiiIds.size()+1] (DiiIds);
        DiiIds[DiiIds.size()-1] =  int'(fieldVal);
        if(dii_indx==0) begin temp_string=""; temp_string = $sformatf("%0s DiiIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DiiIds[dii_indx]);
    //end // for (int i=0; i<nDMIs; i++)	
    <% } %>				   
    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)
if (en_credit_alloc) begin
  concerto_sw_credit_mgr::credit_alloc(AiuIds,DmiIds,DceIds,DiiIds);
end else begin 
  concerto_sw_credit_mgr::get_crdt_cfg(AiuIds,DmiIds,DceIds,DiiIds);
end
concerto_sw_credit_mgr::credit_printer(AiuIds,DmiIds,DceIds,DiiIds);
concerto_sw_credit_mgr::set_csr_crdt<%=qidx%>(AiuIds,DmiIds,DceIds,DiiIds);
concerto_sw_credit_mgr::crdt_adapter<%=qidx%>(AiuIds,DmiIds,DceIds,DiiIds);

`uvm_info("boot_sw_crdt", $sformatf("END BOOT SW CREDIT"), UVM_LOW)
endtask: boot_sw_crdt<%=qidx%>


task concerto_sw_credit_mgr::write_csr_<%=qidx%>(uvm_reg_field field, uvm_reg_data_t wr_data);
    int lsb, msb;
    uvm_reg_data_t mask;
    uvm_reg_data_t field_rd_data;

    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().read(status, field_rd_data, .parent(this));
    <% } else {%>
    uvm_reg_addr_t addr;
    bit [31:0] data;
    addr = field.get_parent().get_address(); 
    addr = addr_trans_mgr_pkg::addrMgrConst::set_addr_as_per_new_nrs(addr);
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        //m_chi_csr_vseq.read_csr_<%=qidx%>(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
            read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    field_rd_data = uvm_reg_data_t'(data);
    <% } %>
    lsb = field.get_lsb_pos();
    msb = lsb + field.get_n_bits() - 1;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Write %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM)
    // and with actual field bits 0
    mask = mask_data(lsb, msb);
    mask = ~mask;
    field_rd_data = field_rd_data & mask;
    // shift write data to appropriate position
    wr_data = wr_data << lsb;
    // then or with this data to get value to write
    wr_data = field_rd_data | wr_data;
    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().write(status, wr_data, .parent(this));
    <% } else {%>
    data=32'(wr_data);
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        //m_chi_csr_vseq.write_csr_<%=qidx%>(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
            write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    <% } %>
endtask : write_csr_<%=qidx%>
//
task concerto_sw_credit_mgr::read_csr_<%=qidx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);
    int lsb, msb;
    uvm_reg_data_t mask;
    uvm_reg_data_t field_rd_data;

    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().read(status, field_rd_data, .parent(this));
    <% } else {%>
    uvm_reg_addr_t addr;
    bit [31:0] data;
    addr = field.get_parent().get_address();  
    addr = addr_trans_mgr_pkg::addrMgrConst::set_addr_as_per_new_nrs(addr);
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        // m_chi_csr_vseq.read_csr_<%=qidx%>(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
            read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    field_rd_data = uvm_reg_data_t'(data);
    <% } %>
    lsb = field.get_lsb_pos();
    msb = lsb + field.get_n_bits() - 1;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_LOW)
    // AND other bits to 0
    mask = mask_data(lsb, msb);
    field_rd_data = field_rd_data & mask;
    // shift read data by lsb to return field
    fieldVal = field_rd_data >> lsb;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d fieldVal=%0d", field.get_name(), lsb, msb,fieldVal), UVM_LOW)
endtask : read_csr_<%=qidx%>

task concerto_sw_credit_mgr::write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data);
    bit nonblocking=0;
    fsys_svt_seq_lib::seq_lib_svt_ace_write_sequence m_iowrnosnp_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
<% var core = 0; 
     for(var i=0; i<qidx+1; i++) { 
      core= aiu_NumCores[i]+core;  
   }
%>
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
//<%=aiu_NumCores[idx]%>
//<%=core%>
    <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
    m_iowrnosnp_seq<%=qidx%>[<%=i%>]   = fsys_svt_seq_lib::seq_lib_svt_ace_write_sequence::type_id::create("m_iowrnosnp_seq<%=qidx%>[<%=i%>]");
    if(nonblocking == 0) begin
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].addr_offset = addr_offset;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myAddr = addr;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].awid = 0;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myData[(addr_offset*8)+:32] = data; //128 =32
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].wstrb = 32'hF<<addr_offset;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].start(concerto_svt_env.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer);
        //m_iowrnosnp_seq<%=qidx%>.start(concerto_svt_env.amba_system_env.axi_system[0].master[0].sequencer);
        `uvm_info("(write_csr)seq_lib_svt_ace_write_sequence--1", $sformatf("addr = %0h, addr_mask = %0h, addr_offset = %0h, data = %0h", addr, addr_mask, addr_offset, data), UVM_NONE)
    end else begin
    fork
        begin
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myAddr = addr;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].awid = 0;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myData[(addr_offset*8)+:32] = data; //128 = 32
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].wstrb = 32'hF<<addr_offset;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].start(concerto_svt_env.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer);
        //m_iowrnosnp_seq<%=qidx%>.start(concerto_svt_env.amba_system_env.axi_system[0].master[0].sequencer);
       `uvm_info("(write_csr)seq_lib_svt_ace_write_sequence--2", $sformatf("addr = %0h, addr_mask = %0h, addr_offset = %0h, data = %0h", addr, addr_mask, addr_offset, data), UVM_NONE)
        end
    join_none
    end // else: !if(nonblocking == 0)
    <% } %>											   
endtask


task concerto_sw_credit_mgr::read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    fsys_svt_seq_lib::seq_lib_svt_ace_read_sequence m_iordnosnp_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
<% var core = 0; 
     for(var i=0; i<qidx+1; i++) { 
      core= aiu_NumCores[i]+core;  
   }%>
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
    m_iordnosnp_seq<%=qidx%>[<%=i%>]   = fsys_svt_seq_lib::seq_lib_svt_ace_read_sequence::type_id::create("m_iordnosnp_seq<%=qidx%>[<%=i%>]");
    m_iordnosnp_seq<%=qidx%>[<%=i%>].myAddr = addr;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].arid = 0;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].addr_offset = addr_offset;
    if(concerto_svt_env==null)
        $display("concerto_svt_env is null");
    else if(concerto_svt_env.amba_system_env==null)
        $display("concerto_svt_env.amba_system_env is null");
    else if(concerto_svt_env.amba_system_env.axi_system[0]==null)
        $display("concerto_svt_env.amba_system_env.axi_system[0] is null");
    else if(concerto_svt_env.amba_system_env.axi_system[0].master[<%=core-1+i%>]==null)
        $display("concerto_svt_env.amba_system_env.axi_system[0].master[<%=core-1+i%>] is null");
    else if(concerto_svt_env.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer==null)
        $display("concerto_svt_env.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer is null");
    m_iordnosnp_seq<%=qidx%>[<%=i%>].start(concerto_svt_env.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer);
    //m_iordnosnp_seq<%=qidx%>.start(concerto_svt_env.amba_system_env.axi_system[0].master[0].sequencer);
   
    //vip zero rddata chk to be added 
    if(addr_offset==0)   rdata[31:0]   =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if(addr_offset==4)   rdata[63:32]  =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if(addr_offset==8)   rdata[95:64]  =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if(addr_offset=='hc) rdata[127:96] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h10) rdata[159:128] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h14) rdata[191:160] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h18) rdata[223:192] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h1c) rdata[255:224] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0]; 
   // rdata[0] =  m_iordnosnp_seq<%=qidx%>.tr.data[0];
    data  = rdata[(addr_offset*8)+:32];
    
    <% } %>											   
    `uvm_info("(read_csr)seq_lib_svt_ace_read_sequence", $sformatf("addr = %0h, addr_mask = %0h, addr_offset = %0h, rdata = 0x%12h, data = 0x%12h", addr, addr_mask, addr_offset, rdata, data), UVM_NONE)
endtask : read_csr<%=qidx%>
    <% //} 
    qidx++; }
    } %>
function uvm_reg_data_t concerto_sw_credit_mgr::mask_data(int lsb, int msb);
    uvm_reg_data_t mask_data_val = 0;
    for(int i=0;i<32;i++)begin
        if(i>=lsb &&  i<=msb)begin
            mask_data_val[i] = 1;     
        end
    end
    return mask_data_val;
  endfunction:mask_data
function void concerto_sw_credit_mgr::parse_str(output string out [], input byte separator, input string in);
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

function void concerto_sw_credit_mgr::credit_alloc(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
string temp_string="";
int numAuis_dce = AiuIds.size();
int numAuis_dmi = AiuIds.size();
int numAuis_dii = AiuIds.size();
int numDces     = DceIds.size();
int findDce[$];
int findDmi[$];
int findDii[$];
int findDce_mrd[$];
int dce_con_idx;
int rand_crdt_en;
int credit_in_use;//used for max credit test computing 
int max_dce_crd;//will take max dce cmd credit calculted for dce to correctely handel random mrd credit
int used_dce_crdt[<%=obj.nDCEs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_dmi_crdt[<%=obj.nDMIs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_dii_crdt[<%=obj.nDIIs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_mrd_crdt[<%=obj.nDMIs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size

if(!$value$plusargs("rand_crdt_en=%d", rand_crdt_en)) begin 
  rand_crdt_en = 0;
end 
foreach (used_mrd_crdt[i]) begin
   used_mrd_crdt[i] = 0 ;
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
    end
    else begin
       parse_str(ioaiu_en_str, "n", ioaiu_en_arg);
       foreach (ioaiu_en_str[i]) begin
	  ioaiu_en[ioaiu_en_str[i].atoi()] = 1;
       end
    end

    foreach(chiaiu_en[i]) begin
      t_chiaiu_en[i]= chiaiu_en[i];
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("chiaiu_en[%0d] = %0d", i, chiaiu_en[i]), UVM_MEDIUM)
    end
    foreach(ioaiu_en[i]) begin
      t_ioaiu_en[i]= ioaiu_en[i];
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("ioaiu_en[%0d] = %0d", i, ioaiu_en[i]), UVM_MEDIUM)
    end

    foreach(t_chiaiu_en[i]) begin
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("t_chiaiu_en[%0d] = %0d", i, t_chiaiu_en[i]), UVM_LOW)

    end
    foreach(t_ioaiu_en[i]) begin
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("t_ioaiu_en[%0d] = %0d", i, t_ioaiu_en[i]), UVM_LOW)
  
    end


active_numChiAiu = $countones(t_chiaiu_en);
active_numIoAiu = $countones(t_ioaiu_en);
numChiAiu = active_numChiAiu;
numIoAiu  = active_numIoAiu;


`uvm_info("credit_alloc-sw_credit_mgr", $sformatf("t_ioaiu_en =%0d active_numChiAiu = %0d active_numIoAiu =%0d numChiAiu = %0d numIoAiu = %0d" ,t_ioaiu_en, active_numChiAiu, active_numIoAiu,numChiAiu,numIoAiu), UVM_LOW)

temp_string="";
    foreach(AiuIds[i]) begin
    int tempCmdCCR=0;
      foreach(DceIds[x]) begin
        findDce = addr_trans_mgr_pkg::addrMgrConst::aiu_connected_dce_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DceIds[x]);
          if (findDce.size() == 0) begin
            //when Dceid is not connected decrease the number of AIU and attribute O credits 
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
            numAuis_dce--;aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = 0;
            en_connectivity_cmd_check = 1;
            `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DceIds[%0d] = %0d" ,i,AiuIds[i],x,DceIds[x] ), UVM_LOW)
          end  else begin
            if (rand_crdt_en==1) begin // random credit is enabled
		        //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
              aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = ($urandom_range(2,(act_cmd_skid_buf_size["DCE"][x]-used_dce_crdt[DceIds[x]])) > VALID_MAX_CREDIT_VALUE/2) ? (VALID_MAX_CREDIT_VALUE/numAuis_dce) : ($urandom_range(2,(act_cmd_skid_buf_size["DCE"][x]-used_dce_crdt[DceIds[x]]))); 
              used_dce_crdt[DceIds[x]]                 =  used_dce_crdt[DceIds[x]] + int'(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]) ;
            end else begin
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
              aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = ((act_cmd_skid_buf_size["DCE"][x]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DCE"][x]/AiuIds.size());
            end 

            if(int'(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]) < 2) begin
                aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = 2;
            end
 
            //calculating of max dce credit allowed
            if(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] > max_dce_crd) begin
              max_dce_crd = int'(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]);
            end
          end
         `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("aCredit_Cmd[%0d][DCE][%0d] = %0d act_cmd_skid_buf_size[DCE][%0d] = %0d" ,AiuIds[i],DceIds[x],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]],x,act_cmd_skid_buf_size["DCE"][x]), UVM_LOW)
        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][DCE][%0d] %0d\n",temp_string,AiuIds[i],DceIds[x],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]);

      end

      numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DmiIds[y]) begin
          findDmi = addr_trans_mgr_pkg::addrMgrConst::aiu_connected_dmi_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DmiIds[y]);
          if (findDmi.size() == 0) begin
            //when Dmiid is not connected decrease the number of AIU and attribute O credits 
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
            numAuis_dmi--;aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = 0;
            en_connectivity_cmd_check = 1;
            `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DmiIds[%0d] = %0d" ,i,AiuIds[i],y,DmiIds[y] ), UVM_LOW)
          end else begin
            if (rand_crdt_en) begin // random credit is enabled
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = ($urandom_range(2,(act_cmd_skid_buf_size["DMI"][y]-used_dmi_crdt[DmiIds[y]])) > VALID_MAX_CREDIT_VALUE) ? (VALID_MAX_CREDIT_VALUE/numAuis_dmi) : ($urandom_range(2,(act_cmd_skid_buf_size["DMI"][y]-used_dmi_crdt[DmiIds[y]])))  ;
            used_dmi_crdt[DmiIds[y]]                 =  used_dmi_crdt[DmiIds[y]] + int'(aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]]) ;
            end else begin
            //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = ((act_cmd_skid_buf_size["DMI"][y]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DMI"][y]/AiuIds.size());
            end 
            if(int'(aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]]) < 2) begin
              aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = 2;
            end

         end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][DMI][%0d] %0d\n",temp_string,AiuIds[i],DmiIds[y],aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DiiIds[z]) begin
              findDii = addr_trans_mgr_pkg::addrMgrConst::aiu_connected_dii_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DiiIds[z]);
              if (findDii.size() == 0) begin
                //when Diiid is not connected decrease the number of AIU and attribute 0 credits 
              numAuis_dii--;aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = 0;
              en_connectivity_cmd_check = 1;
              `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DiiIds[%0d] = %0d" ,i,AiuIds[i],z,DiiIds[z] ), UVM_LOW)
              end else begin
                //if(z<(DiiIds.size()-1)) begin
                  if (rand_crdt_en==1) begin  // random credit is enabled
                  aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = ($urandom_range(2,(act_cmd_skid_buf_size["DII"][z]-used_dii_crdt[DiiIds[z]])) >  VALID_MAX_CREDIT_VALUE/2) ? (VALID_MAX_CREDIT_VALUE/numAuis_dii) : ($urandom_range(2,(act_cmd_skid_buf_size["DII"][z]-used_dii_crdt[DiiIds[z]])));  
                  used_dii_crdt[DiiIds[z]]                = used_dii_crdt[DiiIds[z]] + int'(aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]]);               
                  end else begin
                  aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/AiuIds.size());
                  end 
                  if(int'(aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]]) < 2) begin
                  aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = 2;
                  end
             end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][DII][%0d] %0d\n",temp_string,AiuIds[i],DiiIds[z],aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
    end

    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin    
        dce_con_idx = DceIds[i]- <%=obj.nAIUs%> ;
        findDce_mrd = addr_trans_mgr_pkg::addrMgrConst::dce_connected_dmi_ids[dce_con_idx].ConnectedfUnitIds.find(i) with (i==DmiIds[p]);
        if (findDce_mrd.size() == 0) begin
	      //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
          numDces--; aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 0;
          en_connectivity_mrd_check = 1;
          `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("DceIds[%0d] = %0d is not connected to DmiIds[%0d] = %0d dce_con_idx = %0d"  ,i,DceIds[i],p,DmiIds[p],dce_con_idx ), UVM_LOW)
        end else begin
          if (rand_crdt_en==1) begin
          //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
          //aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = ($urandom_range(max_dce_crd,act_mrd_skid_buf_size["DMI"][p]) < 1) ? 1 : ($urandom_range(max_dce_crd,act_mrd_skid_buf_size["DMI"][p]));   
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]  = ($urandom_range(1,(act_mrd_skid_buf_size["DMI"][p]- used_mrd_crdt[p])/2) > (act_mrd_skid_buf_size["DMI"][p]-used_mrd_crdt[p])/2) ? (act_mrd_skid_buf_size["DMI"][p]/numDces) : ($urandom_range(1,(act_mrd_skid_buf_size["DMI"][p]-used_mrd_crdt[p])/2)); 
          used_mrd_crdt[p]    = used_mrd_crdt[p] + aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] ;     
          end else begin
	        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = ((act_mrd_skid_buf_size["DMI"][p]/numDces) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_mrd_skid_buf_size["DMI"][p]/numDces);
          end 
          if(int'(aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]) < 1) begin
            aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 1;
          end           
        end
        if($test$plusargs("decerr_crdt_mrd_zero_crdt")|| ($test$plusargs("ioaiu_zero_credit"))) begin
	      //#Stimulus.FSYS.address_dec_error.zero_credit.DCE_DMI
          //assign À credit to all agent to check if RTL send a Decode error
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 0;
        end
        if(i<1) numMrdCCR = numMrdCCR+1;
       temp_string = $sformatf("%0saCredit_Mrd[%0d][DMI][%0d] %0d\n",temp_string,DceIds[i],DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] );       
      end
    end
if(!$test$plusargs("max_crdt_test")) begin
end else begin
    <% var ioaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
    <% if(ioaiu_idx == 0){ %>
    foreach(ioaiu_en[i]) begin
      if (ioaiu_en[i]==1) begin
      credit_in_use = credit_in_use + aCredit_Cmd[AiuIds[<%=pidx+1%>]]["DMI"][DmiIds[1]];
      end 
    end
    aCredit_Cmd[AiuIds[<%=pidx%>]]["DMI"][DmiIds[1]]= VALID_MAX_CREDIT_VALUE-credit_in_use;//"-credit_in_use" to avoid allocate all credit to ioaiu 0
    `uvm_info("credit_alloc-sw_credit_mgr max credit testing", $sformatf("aCredit_Cmd[%0d][DMI][%0d]",AiuIds[<%=pidx%>],DmiIds[1],aCredit_Cmd[AiuIds[<%=pidx%>]]["DMI"][DmiIds[0]] ), UVM_LOW)
    <% } %>
       <% ioaiu_idx++; } %>
    <% } %>
end 
//assign zero credit to ioaiu 
if($test$plusargs("ioaiu_zero_credit") || $test$plusargs("chiaiu_zero_credit") )begin
    en_connectivity_cmd_check=0;//disable connectevity check for error testing
       foreach(AiuIds[i]) begin
         if(i != (<%=numChiAiu%>)) begin//not 0 credit for ioaiu0 to be able to boot
           //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DCE
          foreach(DceIds[j]) begin 
            aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]] = 0;
          end
          //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DMI
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]] = 0;
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]] = 0;
          end 
         end                 
    end 

end 
//assign À credit to all agent to check if RTL send a Decode error
if($test$plusargs("decerr_crdt_test")) begin
     foreach(AiuIds[i]) begin
           //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DCE
           foreach(DceIds[j]) begin 
            aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]] = 0;
          end
          //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DMI
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]] = 0;
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]] = 0;
          end                  
    end 
end 
    `uvm_info("credit_alloc-sw_credit_mgr",$sformatf("numMrdCCR %0d numCmdCCR %0d  active_numChiAiu %0d active_numIoAiu %0d",numMrdCCR,numCmdCCR,active_numChiAiu,active_numIoAiu),UVM_NONE)
        
        $display("SOFTWARE CREDIT CMD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      AIU(FunitId)        |      Target(FunitId)      |       Credit        |    Connectivity          |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(AiuIds[i]) begin
      foreach(DceIds[j]) begin 
        $display("|        AIU%0d(%0d)       |       DCE%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],j,DceIds[j],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]]);   
      end
      foreach(DmiIds[k]) begin 
        $display("|         AIU%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],k,DmiIds[k],aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]]);
      end
      foreach(DiiIds[p]) begin 
        $display("|         AIU%0d(%0d)      |       DII%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],p,DiiIds[p],aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]]);
      end                  
end 
        $display("SOFTWARE CREDIT MRD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      DCE(FunitId)        |      DMI(FunitId)         |       Credit         |    Connectivity         |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(DceIds[i]) begin
  foreach(DmiIds[p]) begin
        $display("|         DCE%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,DceIds[i],p,DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]);
  end
end
        $display("------------------------------------------------------------------------------------------------------");  


    `uvm_info("credit_alloc-sw_credit_mgr",$sformatf("%0s",temp_string),UVM_MEDIUM)
   endfunction :credit_alloc

function void concerto_sw_credit_mgr::credit_printer(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);

        $display("SOFTWARE CREDIT CMD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      AIU(FunitId)        |      Target(FunitId)      |       Credit        |    Connectivity          |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(AiuIds[i]) begin
      foreach(DceIds[j]) begin 
        $display("|        AIU%0d(%0d)       |       DCE%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],j,DceIds[j],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]]);   
      end
      foreach(DmiIds[k]) begin 
        $display("|         AIU%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],k,DmiIds[k],aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]]);
      end
      foreach(DiiIds[p]) begin 
        $display("|         AIU%0d(%0d)      |       DII%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],p,DiiIds[p],aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]]);
      end                  
end 
        $display("SOFTWARE CREDIT MRD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      DCE(FunitId)        |      DMI(FunitId)         |       Credit         |    Connectivity         |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(DceIds[i]) begin
  foreach(DmiIds[p]) begin
        $display("|         DCE%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,DceIds[i],p,DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]);
  end
end
        $display("------------------------------------------------------------------------------------------------------");  

endfunction :credit_printer
`endif // `ifdef USE_VIP_SNPS
