////////////////////////////////////////////////////////////
//                                                        //
//Description: provides credits number to each AIU        //
//             agents.                                    //
//                                                        //
//File:        concerto_sw_credit_mgr.svh                 //
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
var Ioaiu_NumCores = [];
var Chiaiu_idx_Tab = [];
var Ioaiu_idx_Tab = [];
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
var numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
var idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
    if(obj.DmiInfo[pidx].useCmc)
       {
         numDmiWithSMC++;
         idxDmiWithSMC = pidx;
       }
}

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
        Chiaiu_idx_Tab[numChiAiu] = obj.AiuInfo[pidx].rpn;
        numChiAiu = numChiAiu + 1;numCAiu++ ;
    } else {
      
    // CLU TMP COMPILE FIX CONC-11383    if ((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_io_idx = numIoAiu;
            csrAccess_ioaiu = numIoAiu;
            found_csr_access_ioaiu = 1;
    //        }
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       numIoAiu_mpu    += obj.AiuInfo[pidx].interfaces.axiInt.length;
       Ioaiu_NumCores[numIoAiu] = obj.AiuInfo[pidx].interfaces.axiInt.length;
       Ioaiu_idx_Tab[numIoAiu] = obj.AiuInfo[pidx].rpn[0];
    } else {
       numIoAiu_mpu++;
       Ioaiu_NumCores[numIoAiu] = 1;
       Ioaiu_idx_Tab[numIoAiu] = obj.AiuInfo[pidx].rpn;
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

var diiIds = obj.DiiInfo.map(item => `${item.nUnitId}:${item.FUnitId}`).join(',');
var dceIds = obj.DceInfo.map(item => `${item.nUnitId}:${item.FUnitId}`).join(',');
var dmiIds = obj.DmiInfo.map(item => `${item.nUnitId}:${item.FUnitId}`).join(',');
var aiuIds = obj.AiuInfo.map(item => { var array = []; // due to case with multiport use rpn instead of nUnitId
                                     if (item.fnNativeInterface.match('CHI')) { 
                                        return `${item.rpn}:${item.FUnitId}`;
                                     } else {
                                        if (Array.isArray(item.rpn)) {  //case multiple port
                                           item.rpn.forEach(element => array.push(`${element}:${item.FUnitId}`));
                                        } else {
                                          array.push(`${item.rpn}:${item.FUnitId}`);
                                        }
                                        return array.join(','); 
                                     }
                                     }                             
                             ).join(',');

%>

<%function generateRegPath(regName) {
    if(obj.DutInfo.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'_0.'+regName;
    } else {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'.'+regName;
    }
}%>

class concerto_sw_credit_mgr extends uvm_component;

 `uvm_component_utils(concerto_sw_credit_mgr)

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
concerto_test_cfg test_cfg;  
concerto_env_pkg::concerto_env_cfg m_concerto_env_cfg;  
concerto_env_pkg::concerto_env     m_concerto_env;
//set credit variable
concerto_test_cfg::t_aCredit aCredit_Cmd;
concerto_test_cfg::t_aCredit aCredit_Mrd;
concerto_register_map_pkg::ral_sys_ncore  m_regs;

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

// ALL ids FUnitIds xxIds[nUnitIds]: Global 
int AiuIds[int];
int AiuIds_en[<%=numChiAiu+numIoAiu_mpu%>];
int AiuIds_credit_min[<%=numChiAiu+numIoAiu_mpu%>];
int DceIds[int];
int DmiIds[int];
int DiiIds[int];
int Ioaiu_idx_Tab[];
int Chiaiu_idx_Tab[];
int Ioaiu_NumCores[];
//constructor
  extern function new(string name = "concerto_sw_credit_mgr", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);

// uvm_phase  
  extern virtual task  ncore_configure_sw_credits();

//functions
  extern function uvm_reg_data_t mask_data(int lsb, int msb);
  extern function void parse_str(output string out[], input byte separator, input string in);
  extern function void credit_alloc();//this function compute the amount of credit to allocate to each aiu
  extern function void credit_printer();//this function compute the amount of credit to allocate to each aiu
  extern function void set_crdt_cfg();// function to get concerto_env.cfg.tCreditXXX must be by DB
  extern function void get_crdt_cfg();// function to get concerto_env.cfg.tCreditXXX must be by DB
  extern function void set_crdt_cfg_perf();
  extern function void set_custom_credit(); 
  extern function void crdt_adapter();// this function adapt credit format from fsys to block format and update block SB 
  extern function void crdt_ioaiu_adapter();

  //task
  // CLU TMP COMPILE FIX CONC-11383     if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  extern  task boot_sw_crdt();
  extern task check_csr();//this function will check skid buffer size 
  extern task write_csr_crdt();// function to get concerto_env.cfg.tCreditXXX must be by DB
  
endclass: concerto_sw_credit_mgr



function concerto_sw_credit_mgr::new(string name = "concerto_sw_credit_mgr", uvm_component parent = null);
  super.new(name,parent);
  AiuIds = '{<%=aiuIds%>}; // assiocative array with idx=rpn:value=FUnitId
  DceIds = '{<%=dceIds%>}; // assiocative array with idx=nUnitId:value=FUnitId
  DmiIds = '{<%=dmiIds%>}; // assiocative array with idx=nUnitId:value=FUnitId
  DiiIds = '{<%=diiIds%>}; // assiocative array with idx=nUnitId:value=FUnitId
  Chiaiu_idx_Tab = '{<%=Chiaiu_idx_Tab%>};
  Ioaiu_idx_Tab = '{<%=Ioaiu_idx_Tab%>};
  Ioaiu_NumCores = '{<%=Ioaiu_NumCores%>};
  <%var nbr_agents = [obj.nDCEs,obj.nDMIs,obj.nDIIs]; // array on nbr of agents%>
  // nbr_agents = <%=nbr_agents%> 
  numCmdCCR = <%=Math.max(...nbr_agents)%>;
  numMrdCCR = <%=obj.nDMIs%>;
  `uvm_info(this.get_full_name(),$sformatf("Chiaiu_idx_Tab = %p",Chiaiu_idx_Tab),UVM_NONE)
  `uvm_info(this.get_full_name(),$sformatf("Ioaiu_idx_Tab = %p",Ioaiu_idx_Tab),UVM_NONE)
  `uvm_info(this.get_full_name(),$sformatf("Ioaiu_NumCores = %p",Ioaiu_NumCores),UVM_NONE)
endfunction: new
// ////////////////////////////////////////////////////////////////////////////
// #     # #     # #     #         ######  #     #    #     #####  #######
// #     # #     # ##   ##         #     # #     #   # #   #     # #
// #     # #     # # # # #         #     # #     #  #   #  #       #
// #     # #     # #  #  #         ######  ####### #     #  #####  #####
// #     #  #   #  #     #         #       #     # #######       # #
// #     #   # #   #     #         #       #     # #     # #     # #
//  #####     #    #     # ####### #       #     # #     #  #####  #######
////////////////////////////////////////////////////////////////////////////
function void concerto_sw_credit_mgr::build_phase(uvm_phase phase);
     if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end   
      if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
     if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_test_cfg object in UVM DB");
    end 

endfunction:build_phase

task  concerto_sw_credit_mgr::ncore_configure_sw_credits(); 
   if (!test_cfg.disable_sw_crdt_mgr_cls && test_cfg.use_new_csr) begin   
     m_regs = m_concerto_env.m_regs;    
    `uvm_info(this.get_full_name(),$sformatf("Launch Software_Credit Sequence"),UVM_LOW)
       // sw credit manager set credit 
       `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("using sw credit manager class"), UVM_LOW)
       if($test$plusargs("use_custom_credit")) begin
          en_credit_alloc = 0; 
          set_custom_credit();
       end // $test$plusargs("use_custom_credit")
       boot_sw_crdt();
      `uvm_info(this.get_full_name(),$sformatf("Leaving Software_Credit Sequence"),UVM_LOW)
   end 	
endtask:ncore_configure_sw_credits

function void concerto_sw_credit_mgr::set_crdt_cfg();
  test_cfg.aCredit_Cmd = aCredit_Cmd;
  test_cfg.aCredit_Mrd = aCredit_Mrd;

endfunction: set_crdt_cfg

function void concerto_sw_credit_mgr::get_crdt_cfg();

     foreach(AiuIds[i]) begin
           foreach(DceIds[j]) begin 
            aCredit_Cmd[i]["DCE"][DceIds[j]] = test_cfg.aCredit_Cmd[i]["DCE"][DceIds[j]];
          end
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[i]["DMI"][DmiIds[k]] = test_cfg.aCredit_Cmd[i]["DMI"][DmiIds[k]];
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[i]["DII"][DiiIds[p]] = test_cfg.aCredit_Cmd[i]["DII"][DiiIds[p]];
          end                  
    end 
    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin
        aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]= test_cfg.aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]];
      end
    end

endfunction: get_crdt_cfg

function void concerto_sw_credit_mgr::set_crdt_cfg_perf();

     if ($test$plusargs("pcie_perf_test")) begin 
      foreach(AiuIds[i]) begin
             foreach(DceIds[j]) begin 
              aCredit_Cmd[i]["DCE"][DceIds[j]] = 8; //since DCESkidBuffer is sized 16(subsys4) and test has 2 AIUs- one producer and one consumer
            end
            foreach(DmiIds[k]) begin 
              aCredit_Cmd[i]["DMI"][DmiIds[k]] = 31;
            end
            foreach(DiiIds[p]) begin 
              aCredit_Cmd[i]["DII"][DiiIds[p]] = 31;
            end
      end 
    end else begin 
     foreach(AiuIds[i]) begin
           foreach(DceIds[j]) begin 
            aCredit_Cmd[i]["DCE"][DceIds[j]] = 31;
          end
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[i]["DMI"][DmiIds[k]] = 31;
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[i]["DII"][DiiIds[p]] = 31;
          end
    end 
   end

    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin
        aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 31;
      end
    end

endfunction: set_crdt_cfg_perf

task concerto_sw_credit_mgr::write_csr_crdt();
uvm_status_e status;
uvm_reg_data_t data,mask,fieldVal;
queue_of_reg regs;
uvm_reg reg_;
uvm_reg_field ral_field;
int rpn;

for(int x=0;x<numCmdCCR;x++) begin:_foreach_CmdCCR
int nDCEs=<%=obj.nDCEs%>;
int nDMIs=<%=obj.nDMIs%>;
int nDIIs=<%=obj.nDIIs%>;
int exp_CounterState_val=0;
  regs =get_q_reg_by_regexpname(m_regs,$sformatf("*AIUCCR%0d",x));
  foreach (regs[reg_]) begin:_foreach_reg_aiu
      rpn = reg_.get_parent().get_field_by_name("RPN").get_reset();  // extract RPN=NUnitId in case of AIU field of the agent: reg_.get_parent
      reg_.read(status,data);
      `uvm_info("(set_credit sw_credit_mgr", $sformatf("Read Reg:%0s  DATA 0x%0h",reg_.get_full_name(), data), UVM_LOW)
      `uvm_info("(set_credit sw_credit_mgr", $sformatf("Corresponding to  rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, x, reg_.get_address(), data), UVM_LOW)
      if (DceIds.exists(x)) begin
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Programming credit aCredit_Cmd[%0d][DCE][%0d] = %0d ",rpn, DceIds[x], aCredit_Cmd[rpn]["DCE"][DceIds[x]]), UVM_MEDIUM)
        ral_fill_field(reg_, "DCECreditLimit",data,aCredit_Cmd[rpn]["DCE"][DceIds[x]]);
      end
      if (DmiIds.exists(x)) begin
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Programming credit aCredit_Cmd[%0d][DMI][%0d] = %0d ",rpn, DmiIds[x], aCredit_Cmd[rpn]["DMI"][DmiIds[x]]), UVM_MEDIUM)
        ral_fill_field(reg_, "DMICreditLimit",data,aCredit_Cmd[rpn]["DMI"][DmiIds[x]]);
      end
      if (DiiIds.exists(x)) begin
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Programming credit aCredit_Cmd[%0d][DII][%0d] = %0d ",rpn, DiiIds[x], aCredit_Cmd[rpn]["DII"][DiiIds[x]]), UVM_MEDIUM)
        ral_fill_field(reg_, "DIICreditLimit",data,aCredit_Cmd[rpn]["DII"][DiiIds[x]]);
      end
      reg_.write(status,data);
     `uvm_info("(set_credit sw_credit_mgr", $sformatf("Writing rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, x, reg_.get_address(), data), UVM_LOW)
      //check nonconnected register field 
      //#Check.FSYS.RDCCRstate.noconnection
        if (en_connectivity_cmd_check) begin 
          reg_.read(status,data);
          if(x<nDCEs) begin
            exp_CounterState_val = 7; 
          end else begin
            exp_CounterState_val = 0; 
          end
          if (aCredit_Cmd[rpn]["DCE"][DceIds[x]] == 0 && data[7:5] != exp_CounterState_val) begin 
            `uvm_error("write_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DCE with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be %0d No Connection ",DceIds[x],AiuIds[rpn],data[7:5],exp_CounterState_val))
          end
          if(x<nDMIs) begin
            exp_CounterState_val = 7; 
          end else begin
            exp_CounterState_val = 0; 
          end
          if (aCredit_Cmd[rpn]["DMI"][DmiIds[x]] == 0 && data[15:13] != exp_CounterState_val) begin 
            `uvm_error("write_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DMI with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be %0d No Connection ",DmiIds[x],AiuIds[rpn],data[15:13],exp_CounterState_val))
          end  
          if(x<nDIIs) begin
            exp_CounterState_val = 7; 
          end else begin
            exp_CounterState_val = 0; 
          end
          if (aCredit_Cmd[rpn]["DII"][DiiIds[x]] == 0 && data[23:21] != exp_CounterState_val) begin 
            `uvm_error("write_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DII with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be %0d No Connection ",DmiIds[x],AiuIds[rpn],data[23:21],exp_CounterState_val))
          end  
        end 
  end:_foreach_reg_aiu
  if (DmiIds.exists(x)) begin: _dmi_exist
    regs =get_q_reg_by_regexpname(m_regs,$sformatf("*DCEUCCR%0d",x));
    foreach (regs[reg_]) begin:_foreach_reg_dce
      int id = reg_.get_parent().get_field_by_name("NUnitId").get_reset();  // extract RPN field of the agent: reg_.get_parent
      rpn = reg_.get_parent().get_field_by_name("RPN").get_reset();  // extract RPN field of the agent: reg_.get_parent
      reg_.read(status,data);
      `uvm_info("(set_credit sw_credit_mgr", $sformatf("Read Reg:%0s  DATA 0x%0h",reg_.get_full_name(), data), UVM_LOW)
      `uvm_info("(set_credit sw_credit_mgr", $sformatf("Corresponding rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, x, reg_.get_address(), data), UVM_LOW)
      ral_fill_field(reg_, "DMICreditLimit",data,aCredit_Mrd[DceIds[id]]["DMI"][DmiIds[x]]); ///!! use id instead of rpn!!
      `uvm_info("(set_credit sw_credit_mgr", $sformatf("Programming credit aCredit_Mrd[%0d][DMI][%0d] = %0d ",id, DmiIds[x], aCredit_Mrd[DceIds[id]]["DMI"][DmiIds[x]]), UVM_MEDIUM)
      reg_.write(status,data);
      `uvm_info("(set_credit sw_credit_mgr", $sformatf("Writing rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, x, reg_.get_address(), data), UVM_LOW)
    end:_foreach_reg_dce
  end:_dmi_exist
end:_foreach_CmdCCR
endtask: write_csr_crdt

task concerto_sw_credit_mgr::check_csr();
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
uvm_status_e  status;
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

  
  m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nAIUs").read(status,fieldVal);//data[ 7: 0];
  nAIUs = int'(fieldVal);
  m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDCEs").read(status,fieldVal);//data[ 7: 0];
  nDCEs = int'(fieldVal);
  m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDMIs").read(status,fieldVal);//data[ 7: 0];
  nDMIs = int'(fieldVal);
  m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDIIs").read(status,fieldVal);//data[ 7: 0];
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
  m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.DCEUSBSIR.get_field_by_name("SkidBufArb").read(status,fieldVal);
  act_cmd_skid_buf_arb["DCE"][dce_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DCE REG] Reading  DCEUSBSIR SkidBufArb:act_cmd_skid_buf_arb[DCE][%0d]=%0d ",dce_indx,act_cmd_skid_buf_arb["DCE"][dce_indx]), UVM_LOW)
  m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.DCEUSBSIR.get_field_by_name("SkidBufSize").read(status,fieldVal);
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
  m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("MRDSBSIR").get_field_by_name("SkidBufArb").read(status,fieldVal);
  act_mrd_skid_buf_arb["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  MRDSBSIR act_mrd_skid_buf_arb[DMI][%0d]=%0d ",dmi_indx,act_mrd_skid_buf_arb["DMI"][dmi_indx]), UVM_LOW)
  m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("MRDSBSIR").get_field_by_name("SkidBufSize").read(status,fieldVal);
  act_mrd_skid_buf_size["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  MRDSBSIR SkidBufSize:act_mrd_skid_buf_size[DMI][%0d]=%0d ",dmi_indx,act_mrd_skid_buf_size["DMI"][dmi_indx]), UVM_LOW)

  m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("CMDSBSIR").get_field_by_name("SkidBufArb").read(status,fieldVal);
  act_cmd_skid_buf_arb["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  CMDSBSIR act_cmd_skid_buf_arb[DMI][%0d]=%0d ",dmi_indx,act_cmd_skid_buf_arb["DMI"][dmi_indx]), UVM_LOW)
  m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("CMDSBSIR").get_field_by_name("SkidBufSize").read(status,fieldVal);
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
  m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUSBSIR").get_field_by_name("SkidBufSize").read(status,fieldVal);
  act_cmd_skid_buf_size["DII"][dii_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DII REG] Reading  DIIUSBSIR SkidBufSize:act_cmd_skid_buf_size[DII][%0d]=%0d fieldVal = %0d",dii_indx,act_cmd_skid_buf_size["DII"][dii_indx],fieldVal), UVM_LOW)
  m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUSBSIR").get_field_by_name("SkidBufArb").read(status,fieldVal);
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
endtask:check_csr 

task   concerto_sw_credit_mgr::boot_sw_crdt();
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

`uvm_info("boot_sw_crdt", $sformatf("Start BOOT SW CREDIT"), UVM_LOW)
concerto_sw_credit_mgr::check_csr();

if (($test$plusargs("perf_test") && $test$plusargs("sequential")) || $test$plusargs("pcie_perf_test")) begin
  set_crdt_cfg_perf();
end else if (en_credit_alloc) begin
  credit_alloc();
end else begin 
  get_crdt_cfg();
end

credit_printer();
write_csr_crdt();
crdt_adapter();

`uvm_info("boot_sw_crdt", $sformatf("END BOOT SW CREDIT"), UVM_LOW)
endtask: boot_sw_crdt

/////////////////////////////////////////////////////////////////////
// ######  #    #  #    #   ####    #####     #     ####   #    #
// #       #    #  ##   #  #    #     #       #    #    #  ##   #
// #####   #    #  # #  #  #          #       #    #    #  # #  #
// #       #    #  #  # #  #          #       #    #    #  #  # #
// #       #    #  #   ##  #    #     #       #    #    #  #   ##
// #        ####   #    #   ####      #       #     ####   #    #
/////////////////////////////////////////////////////////////////////
function void concerto_sw_credit_mgr::crdt_adapter();
//
string dce_credit_msg="";
int new_dce_credits;

<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      for(int x=0;x<numMrdCCR;x++) begin
        $sformat(dce_credit_msg, "dce%0d_dmi%0d_nMrdInFlight", DceIds[<%=pidx%>], DmiIds[x]);
        //new_dce_credits=test_cfg.aCredit_Mrd[DceIds[<%=pidx%>]]["DMI"][DmiIds[x]];
        new_dce_credits=aCredit_Mrd[DceIds[<%=pidx%>]]["DMI"][DmiIds[x]];
        if(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.has_scoreboard)begin
          m_concerto_env.inhouse.m_dce<%=pidx%>_env.m_dce_scb.m_credits.scm_credit(dce_credit_msg, new_dce_credits);
        end
      end
<% } %>

// call ioaiu adapter
  if($test$plusargs("scm_use_ioaiu_adapter")) begin
    crdt_ioaiu_adapter();
  end
endfunction: crdt_adapter

function void concerto_sw_credit_mgr::crdt_ioaiu_adapter();

//concerto_sw_credit_mgr::get_crdt_cfg();
  <% for(var ioaiu_idx = 0, pidx = 0 ; pidx < obj.nAIUs; pidx++) { 
     if(!((obj.AiuInfo[pidx].fnNativeInterface.match('CHI')))) { 
      for(var core_idx=0; core_idx<aiu_NumCores[pidx]; core_idx++) { %>
        foreach(DceIds[j]) begin 
          if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
            m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].dceCreditLimit[DceIds[j]]=int'(aCredit_Cmd[<%=ioaiu_idx%>]["DCE"][DceIds[j]]);
          end 
        end
    

        foreach(DmiIds[k]) begin          
          if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
            m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].dmiCreditLimit[DmiIds[k]]=int'(aCredit_Cmd[<%=ioaiu_idx%>]["DMI"][DmiIds[k]]);
          end
        end

       foreach(DiiIds[p]) begin 
        if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
          m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].diiCreditLimit[DiiIds[p]]=int'(aCredit_Cmd[<%=ioaiu_idx%>]["DII"][DiiIds[p]]);
        end
       end
<% } 
 ioaiu_idx++; }
 } %> 
endfunction: crdt_ioaiu_adapter

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

function void concerto_sw_credit_mgr::credit_alloc();
string temp_string="";
int numAuis_dce = AiuIds.size();
int numAuis_dmi = AiuIds.size();
int numAuis_dii = AiuIds.size();
int numDces     = DceIds.size();
int findDce[$];
int findDmi[$];
int findDii[$];
int findDce_mrd[$];
int findDmi_Aius[$];
int findDce_Aius[$];
int findDii_Aius[$];
int Dmi_connected_Dce[int][$];
//int Dmi_connected_Aiu[int][$];
//int Dce_connected_Aiu[int][$];
//int Dii_connected_Aiu[int][$];

int Dmi_connected_Aiu[$];
int Dce_connected_Aiu[$];
int Dii_connected_Aiu[$];
int dce_con_idx;
int rand_crdt_en;
int credit_in_use;//used for max credit test computing 
int max_dce_crd;//will take max dce cmd credit calculted for dce to correctely handel random mrd credit
int used_dce_crdt[int];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_dmi_crdt[int];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_dii_crdt[int];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_mrd_crdt[int];//used to respect constraint:the total number of credit hsould not exceed the buffer size

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
    //init min credit for AIUs
    foreach(Chiaiu_idx_Tab[i]) begin
      AiuIds_credit_min[Chiaiu_idx_Tab[i]] = 1;
    end
    foreach(Ioaiu_NumCores[i]) begin
      for (int core_nb=0; core_nb < Ioaiu_NumCores[i]; core_nb++) begin    
        AiuIds_credit_min[Ioaiu_idx_Tab[i]+core_nb] = 2;
      end
    end
    
    foreach(chiaiu_en[i]) begin
      t_chiaiu_en[i]= chiaiu_en[i];
      AiuIds_en[Chiaiu_idx_Tab[i]] = 1;
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("chiaiu_en[%0d] = %0d", i, chiaiu_en[i]), UVM_MEDIUM)
    end
    foreach(ioaiu_en[i]) begin
      t_ioaiu_en[i]= ioaiu_en[i]; 
      for (int core_nb=0; core_nb < Ioaiu_NumCores[i]; core_nb++) begin    
        AiuIds_en[Ioaiu_idx_Tab[i]+core_nb] = 1;
      end
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("ioaiu_en[%0d] = %0d", i, ioaiu_en[i]), UVM_MEDIUM)
    end
    
    foreach(AiuIds_en[i]) begin
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds_en[%0d] = %0d, AiuIds_credit_min[%0d] = %0d", i, AiuIds_en[i], i, AiuIds_credit_min[i]), UVM_NONE)
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
    //calculate number of AIU connected to a DMI, update available credits for connected AIUS
    foreach(DmiIds[p]) begin   
      int aiu_dmi_credit_mult, aiu_dmi_credit_rest, used_dmi_crdt_tmp, Dmi_connected_Aiu[$];
      //start by assesing connected AIUs and setting minimum credits in AIUs   
      foreach(AiuIds[i]) begin
        findDmi_Aius = ncore_config_pkg::ncoreConfigInfo::aiu_connected_dmi_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DmiIds[p]);
        if (findDmi_Aius.size() == 0) begin
	        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
          aCredit_Cmd[i]["DMI"][DmiIds[p]] = 0;
          en_connectivity_cmd_check = 1;
          `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DmiIds[%0d] = %0d" ,i,AiuIds[i],p,DmiIds[p] ), UVM_LOW)          
        end else begin            
          if (AiuIds_en[i]) begin
            //Dmi_connected_Aiu[DmiIds[p]] = {Dmi_connected_Aiu[DmiIds[p]], findDmi_Aius};
            Dmi_connected_Aiu.push_back(i);
          end 

          //check if we still have enough credits
          if(int'(act_cmd_skid_buf_size["DMI"][p]) < AiuIds_credit_min[i]) begin
              //force minimum credit if not able to correct a wrong config
              if($test$plusargs("force_dmi_min_credit")) begin
                `uvm_warning("credit_alloc-sw_credit_mgr",$sformatf("Remaining DMI credit %0d is less than needed %0d credits for accessing DmiIds[%0d] = %0d while configuring AiuIds[%0d] = %0d",int'(act_cmd_skid_buf_size["DMI"][p]),AiuIds_credit_min[i],p,DmiIds[p],i,AiuIds[i]))
              end else begin
                `uvm_error("credit_alloc-sw_credit_mgr",$sformatf("Remaining DMI credit %0d is less than needed %0d credits for accessing DmiIds[%0d] = %0d while configuring AiuIds[%0d] = %0d",int'(act_cmd_skid_buf_size["DMI"][p]),AiuIds_credit_min[i],p,DmiIds[p],i,AiuIds[i]))
              end
          end else begin
            //remove the minimum credit from the remaining available credits of DmiIds[p]
            act_cmd_skid_buf_size["DMI"][p] -= AiuIds_credit_min[i];
          end
          //set minimum credit for the connected AIU
          aCredit_Cmd[i]["DMI"][DmiIds[p]] = AiuIds_credit_min[i];
        end
      end
      
      //distribute remaining credits
      if (rand_crdt_en==1) begin // random credit is enabled
        //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
        foreach(Dmi_connected_Aiu[x]) begin
          aCredit_Cmd[Dmi_connected_Aiu[x]]["DMI"][DmiIds[p]] += ($urandom_range(0,(act_cmd_skid_buf_size["DMI"][p]-used_dmi_crdt_tmp)) > VALID_MAX_CREDIT_VALUE/2) ? (VALID_MAX_CREDIT_VALUE/Dmi_connected_Aiu.size()) : 
                                                                         ($urandom_range(0,(act_cmd_skid_buf_size["DMI"][p]-used_dmi_crdt_tmp))); 
          used_dmi_crdt_tmp                 +=  int'(aCredit_Cmd[Dmi_connected_Aiu[x]]["DMI"][DmiIds[p]]);
        end
      end else begin
        //equalize credits
        foreach(Dmi_connected_Aiu[x]) begin
          if (aCredit_Cmd[Dmi_connected_Aiu[x]]["DMI"][DmiIds[p]] == 1 && act_cmd_skid_buf_size["DMI"][p] > 0) begin
            aCredit_Cmd[Dmi_connected_Aiu[x]]["DMI"][DmiIds[p]] += 1;
            act_cmd_skid_buf_size["DMI"][p] -=1;
          end
        end

        aiu_dmi_credit_mult = act_cmd_skid_buf_size["DMI"][p]/Dmi_connected_Aiu.size();
        aiu_dmi_credit_rest = act_cmd_skid_buf_size["DMI"][p]%Dmi_connected_Aiu.size();

        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
        if (aiu_dmi_credit_mult > 0) begin
          foreach(Dmi_connected_Aiu[x]) begin
            aCredit_Cmd[Dmi_connected_Aiu[x]]["DMI"][DmiIds[p]] += aiu_dmi_credit_mult;
          end
        end        
        if (aiu_dmi_credit_rest >0  ) begin
          while (aiu_dmi_credit_rest > 0) begin          
            aCredit_Cmd[Dmi_connected_Aiu[aiu_dmi_credit_rest]]["DMI"][DmiIds[p]] += 1;
            aiu_dmi_credit_rest -=1;
          end
        end
      end
      //check no credit is exceding the limit VALID_MAX_CREDIT_VALUE
      foreach(Dmi_connected_Aiu[x]) begin
        if (aCredit_Cmd[Dmi_connected_Aiu[x]]["DMI"][DmiIds[p]] > VALID_MAX_CREDIT_VALUE) begin
          aCredit_Cmd[Dmi_connected_Aiu[x]]["DMI"][DmiIds[p]] = VALID_MAX_CREDIT_VALUE;
        end
      end
    end
    
    //calculate number of AIU connected to a DII, update available credits for connected AIUS
    foreach(DiiIds[p]) begin 
      int aiu_dii_credit_mult, aiu_dii_credit_rest, used_dii_crdt_tmp,  Dii_connected_Aiu[$];
      //start by assesing connected AIUs and setting minimum credits in AIUs     
      foreach(AiuIds[i]) begin
        findDii_Aius = ncore_config_pkg::ncoreConfigInfo::aiu_connected_dii_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DiiIds[p]);
        if (findDii_Aius.size() == 0) begin
	        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
          aCredit_Cmd[i]["DII"][DiiIds[p]] = 0;
          en_connectivity_cmd_check = 1;
          `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DiiIds[%0d] = %0d" ,i,AiuIds[i],p,DiiIds[p] ), UVM_LOW)          
        end else begin            
          if (AiuIds_en[i]) begin
            //Dii_connected_Aiu[DiiIds[p]] = {Dii_connected_Aiu[DiiIds[p]], findDii_Aius};
            Dii_connected_Aiu.push_back(i);
          end 
          

          //check if we still have enough credits
          if(int'(act_cmd_skid_buf_size["DII"][p]) < AiuIds_credit_min[i]) begin
              //force minimum credit if not able to correct a wrong config
              if($test$plusargs("force_dii_min_credit")) begin
                `uvm_warning("credit_alloc-sw_credit_mgr",$sformatf("Remaining DII credit %0d is less than needed %0d credits for accessing DiiIds[%0d] = %0d while configuring AiuIds[%0d] = %0d",int'(act_cmd_skid_buf_size["DII"][p]),AiuIds_credit_min[i],p,DiiIds[p],i,AiuIds[i]))
              end else begin
                `uvm_error("credit_alloc-sw_credit_mgr",$sformatf("Remaining DII credit %0d is less than needed %0d credits for accessing DiiIds[%0d] = %0d while configuring AiuIds[%0d] = %0d",int'(act_cmd_skid_buf_size["DII"][p]),AiuIds_credit_min[i],p,DiiIds[p],i,AiuIds[i]))
              end
          end else begin
            //remove the min credit from the remaining available credits of DiiIds[p]
            act_cmd_skid_buf_size["DII"][p] -= AiuIds_credit_min[i];
          end
          //set minimum credit for the connected AIU
          aCredit_Cmd[i]["DII"][DiiIds[p]] = AiuIds_credit_min[i];
        end
      end
      
      //distribute remaining credits
      if (rand_crdt_en==1) begin // random credit is enabled
        //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
        foreach(Dii_connected_Aiu[x]) begin
          aCredit_Cmd[Dii_connected_Aiu[x]]["DII"][DiiIds[p]] += ($urandom_range(0,(act_cmd_skid_buf_size["DII"][p]-used_dii_crdt_tmp)) > VALID_MAX_CREDIT_VALUE/2) ? (VALID_MAX_CREDIT_VALUE/Dii_connected_Aiu.size()) : 
                                                                        ($urandom_range(0,(act_cmd_skid_buf_size["DII"][p]-used_dii_crdt_tmp))); 
          used_dii_crdt_tmp                 +=  int'(aCredit_Cmd[Dii_connected_Aiu[x]]["DII"][DiiIds[p]]);
        end
      end else begin
        //equalize credits
        foreach(Dii_connected_Aiu[x]) begin
          if (aCredit_Cmd[Dii_connected_Aiu[x]]["DII"][DiiIds[p]] == 1 && act_cmd_skid_buf_size["DII"][p] > 0) begin
            aCredit_Cmd[Dii_connected_Aiu[x]]["DII"][DiiIds[p]] += 1;
            act_cmd_skid_buf_size["DII"][p] -=1;
          end
        end
        aiu_dii_credit_mult = act_cmd_skid_buf_size["DII"][p]/Dii_connected_Aiu.size();
        aiu_dii_credit_rest = act_cmd_skid_buf_size["DII"][p]%Dii_connected_Aiu.size();
        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
        if (aiu_dii_credit_mult > 0) begin
          foreach(Dii_connected_Aiu[x]) begin
            aCredit_Cmd[Dii_connected_Aiu[x]]["DII"][DiiIds[p]] += aiu_dii_credit_mult;
          end
        end        
        if (aiu_dii_credit_rest >0) begin
          while (aiu_dii_credit_rest > 0) begin
            aCredit_Cmd[Dii_connected_Aiu[aiu_dii_credit_rest]]["DII"][DiiIds[p]] += 1;
            aiu_dii_credit_rest -=1;
          end
        end
      end
      //check no credit is exceding the limit VALID_MAX_CREDIT_VALUE
      foreach(Dii_connected_Aiu[x]) begin
        if (aCredit_Cmd[Dii_connected_Aiu[x]]["DII"][DiiIds[p]] > VALID_MAX_CREDIT_VALUE) begin
          aCredit_Cmd[Dii_connected_Aiu[x]]["DII"][DiiIds[p]] = VALID_MAX_CREDIT_VALUE;
        end
      end        
    end

    //calculate number of AIU connected to a DCE, update available credits for connected AIUS
    foreach(DceIds[p]) begin
      int aiu_dce_credit_mult, aiu_dce_credit_rest, used_dce_crdt_tmp, Dce_connected_Aiu[$];
      //start by assesing connected AIUs and setting minimum credits in AIUs       
      foreach(AiuIds[i]) begin        
          findDce_Aius = ncore_config_pkg::ncoreConfigInfo::aiu_connected_dce_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DceIds[p]);
          if (findDce_Aius.size() == 0) begin
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
            aCredit_Cmd[i]["DCE"][DceIds[p]] = 0;
            en_connectivity_cmd_check = 1;
            `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DceIds[%0d] = %0d" ,i,AiuIds[i],p,DceIds[p] ), UVM_LOW)          
          end else begin            
            if (AiuIds_en[i]) begin
              //Dce_connected_Aiu[DceIds[p]] = {Dce_connected_Aiu[DceIds[p]], findDce_Aius};
              Dce_connected_Aiu.push_back(i);
            end 

            if(int'(act_cmd_skid_buf_size["DCE"][p]) < AiuIds_credit_min[i]) begin
              `uvm_error("credit_alloc-sw_credit_mgr",$sformatf("Remaining DCE credit %0d is less than needed %0d credits for accessing DceIds[%0d] = %0d while configuring AiuIds[%0d] = %0d",int'(act_cmd_skid_buf_size["DCE"][p]),AiuIds_credit_min[i],p,DceIds[p],i,AiuIds[i]))
            end 
            //set minimum credit for the connected AIU
            aCredit_Cmd[i]["DCE"][DceIds[p]] = AiuIds_credit_min[i];
            //remove the set credit from the remaining available credits of DmiIds[p]
            act_cmd_skid_buf_size["DCE"][p] -= AiuIds_credit_min[i];
          end
      end
      
      //distribute remaining credits
      if (rand_crdt_en==1) begin // random credit is enabled
        //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
        foreach(Dce_connected_Aiu[x]) begin
          aCredit_Cmd[Dce_connected_Aiu[x]]["DCE"][DceIds[p]] += ($urandom_range(0,(act_cmd_skid_buf_size["DCE"][p]-used_dce_crdt_tmp)) > VALID_MAX_CREDIT_VALUE/2) ? (VALID_MAX_CREDIT_VALUE/Dce_connected_Aiu.size()) : 
                                                                        ($urandom_range(0,(act_cmd_skid_buf_size["DCE"][p]-used_dce_crdt_tmp))); 
          used_dce_crdt_tmp                 +=  int'(aCredit_Cmd[Dce_connected_Aiu[x]]["DCE"][DceIds[p]]);
        end
      end else begin
        //equalize credits
        foreach(Dce_connected_Aiu[x]) begin
          if (aCredit_Cmd[Dce_connected_Aiu[x]]["DCE"][DceIds[p]] == 1 && act_cmd_skid_buf_size["DCE"][p] > 0) begin
            aCredit_Cmd[Dce_connected_Aiu[x]]["DCE"][DceIds[p]] += 1;
            act_cmd_skid_buf_size["DCE"][p] -=1;
          end
        end
        aiu_dce_credit_mult = act_cmd_skid_buf_size["DCE"][p]/Dce_connected_Aiu.size();
        aiu_dce_credit_rest = act_cmd_skid_buf_size["DCE"][p]%Dce_connected_Aiu.size();
        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
        if (aiu_dce_credit_mult > 0) begin
          foreach(Dce_connected_Aiu[x]) begin
            aCredit_Cmd[Dce_connected_Aiu[x]]["DCE"][DceIds[p]] += aiu_dce_credit_mult;
          end
        end        
        if (aiu_dce_credit_rest >0) begin
          while (aiu_dce_credit_rest > 0) begin
            aCredit_Cmd[Dce_connected_Aiu[aiu_dce_credit_rest]]["DCE"][DceIds[p]] += 1;
            aiu_dce_credit_rest -=1;
          end
        end
      end
      //check no credit is exceding the limit VALID_MAX_CREDIT_VALUE
      foreach(Dce_connected_Aiu[x]) begin
        if (aCredit_Cmd[Dce_connected_Aiu[x]]["DCE"][DceIds[p]] > VALID_MAX_CREDIT_VALUE) begin
          aCredit_Cmd[Dce_connected_Aiu[x]]["DCE"][DceIds[p]] = VALID_MAX_CREDIT_VALUE;
        end
      end
    end

    //AE calcuated number of DCE connected to a DMI
    foreach(DmiIds[p]) begin      
      foreach(DceIds[i]) begin
        dce_con_idx = DceIds[i]- <%=obj.nAIUs%> ;
        findDce_mrd = ncore_config_pkg::ncoreConfigInfo::dce_connected_dmi_ids[dce_con_idx].ConnectedfUnitIds.find(i) with (i==DmiIds[p]);
        if (findDce_mrd.size() != 0) Dmi_connected_Dce[DmiIds[p]] = {Dmi_connected_Dce[DmiIds[p]], findDce_mrd};
      end
    end

    foreach(DceIds[i]) begin
      dce_con_idx = DceIds[i]- <%=obj.nAIUs%> ;

      foreach(DmiIds[p]) begin    
        //AE dce_con_idx = DceIds[i]- <%=obj.nAIUs%> ;
        findDce_mrd = ncore_config_pkg::ncoreConfigInfo::dce_connected_dmi_ids[dce_con_idx].ConnectedfUnitIds.find(i) with (i==DmiIds[p]);

        if (findDce_mrd.size() == 0) begin
	      //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 0;
          en_connectivity_mrd_check = 1;
          `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("DceIds[%0d] = %0d is not connected to DmiIds[%0d] = %0d dce_con_idx = %0d"  ,i,DceIds[i],p,DmiIds[p],dce_con_idx ), UVM_LOW)
        end else begin
          if (rand_crdt_en==1) begin
          //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
          //aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = ($urandom_range(max_dce_crd,act_mrd_skid_buf_size["DMI"][p]) < 1) ? 1 : ($urandom_range(max_dce_crd,act_mrd_skid_buf_size["DMI"][p]));   
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]  = ($urandom_range(2,(act_mrd_skid_buf_size["DMI"][p]- used_mrd_crdt[p])/2) > (act_mrd_skid_buf_size["DMI"][p]-used_mrd_crdt[p])/2) ? (act_mrd_skid_buf_size["DMI"][p]/numDces) : ($urandom_range(2,(act_mrd_skid_buf_size["DMI"][p]-used_mrd_crdt[p])/2)); 
          used_mrd_crdt[p]    = used_mrd_crdt[p] + aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] ;     
          end else begin
	        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = ((act_mrd_skid_buf_size["DMI"][p]/Dmi_connected_Dce[DmiIds[p]].size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_mrd_skid_buf_size["DMI"][p]/Dmi_connected_Dce[DmiIds[p]].size());
          end 
          if(int'(aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]) < 1) begin
            aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 1;
          end           
        end
       temp_string = $sformatf("%0saCredit_Mrd[%0d][DMI][%0d] %0d\n",temp_string,DceIds[i],DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] );       
      end //foreach dmi
    end
if(!$test$plusargs("max_crdt_test")) begin
end else begin
    <% var ioaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
    <% if(ioaiu_idx == 0){ %>
    foreach(ioaiu_en[i]) begin
      if (ioaiu_en[i]==1) begin
      credit_in_use = credit_in_use + aCredit_Cmd[<%=pidx+1%>]["DMI"][DmiIds[1]];
      end 
    end
    aCredit_Cmd[<%=pidx%>]["DMI"][DmiIds[1]]= VALID_MAX_CREDIT_VALUE-credit_in_use;//"-credit_in_use" to avoid allocate all credit to ioaiu 0
    `uvm_info("credit_alloc-sw_credit_mgr max credit testing", $sformatf("aCredit_Cmd[%0d][DMI][%0d]",<%=pidx%>,DmiIds[1],aCredit_Cmd[<%=pidx%>]["DMI"][DmiIds[0]] ), UVM_LOW)
    <% } %>
       <% ioaiu_idx++; } %>
    <% } %>
end 
//assign zero credit to ioaiu 
if($test$plusargs("ioaiu_zero_credit") || $test$plusargs("chiaiu_zero_credit") )begin
    en_connectivity_cmd_check=0;//disable connectevity check for error testing
       foreach(AiuIds[i]) begin
           //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DCE
          foreach(DceIds[j]) begin 
            aCredit_Cmd[i]["DCE"][DceIds[j]] = 0;
          end
          //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DMI
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[i]["DMI"][DmiIds[k]] = 0;
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[i]["DII"][DiiIds[p]] = 0;
          end             
    end 
    ncore_config_pkg::ncoreConfigInfo::dmi_credit_zero = 32'hFFFF_FFFF;
    ncore_config_pkg::ncoreConfigInfo::dii_credit_zero = 32'hFFFF_FFFF;
    ncore_config_pkg::ncoreConfigInfo::dce_credit_zero = 32'hFFFF_FFFF;

end 
if($test$plusargs("decerr_crdt_mrd_zero_crdt")|| ($test$plusargs("ioaiu_zero_credit"))) begin
  //#Stimulus.FSYS.address_dec_error.zero_credit.DCE_DMI
  //assign 0 credit to all agent to check if RTL send a Decode error
    foreach(DceIds[i]) begin
        foreach(DmiIds[p]) begin 
        if (p == <%=idxDmiWithSMC%>) 
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 0;
        end
    end
end
//assign À credit to all agent to check if RTL send a Decode error
if($test$plusargs("decerr_crdt_test")) begin
     foreach(AiuIds[i]) begin
           //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DCE
           foreach(DceIds[j]) begin 
            aCredit_Cmd[i]["DCE"][DceIds[j]] = 0;
          end
          //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DMI
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[i]["DMI"][DmiIds[k]] = 0;
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[i]["DII"][DiiIds[p]] = 0;
          end                  
    end 
end 
    `uvm_info("credit_alloc-sw_credit_mgr",$sformatf("numMrdCCR %0d numCmdCCR %0d  active_numChiAiu %0d active_numIoAiu %0d",numMrdCCR,numCmdCCR,active_numChiAiu,active_numIoAiu),UVM_NONE) 


    `uvm_info("credit_alloc-sw_credit_mgr",$sformatf("%0s",temp_string),UVM_MEDIUM)
   endfunction :credit_alloc

function void concerto_sw_credit_mgr::credit_printer();

        $display("SOFTWARE CREDIT CMD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      AIU(FunitId)        |      Target(FunitId)      |       Credit        |    Connectivity          |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(AiuIds[i]) begin
      foreach(DceIds[j]) begin 
        $display("|        AIU%0d(%0d)           |       DCE%0d(%0d)             |         %0d           |                         |",i,AiuIds[i],j,DceIds[j],aCredit_Cmd[i]["DCE"][DceIds[j]]);   
      end
      foreach(DmiIds[k]) begin 
        $display("|        AIU%0d(%0d)           |       DMI%0d(%0d)             |         %0d           |                         |",i,AiuIds[i],k,DmiIds[k],aCredit_Cmd[i]["DMI"][DmiIds[k]]);
      end
      foreach(DiiIds[p]) begin 
        $display("|        AIU%0d(%0d)           |       DII%0d(%0d)             |         %0d           |                         |",i,AiuIds[i],p,DiiIds[p],aCredit_Cmd[i]["DII"][DiiIds[p]]);
      end                  
end 
        $display("SOFTWARE CREDIT MRD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      DCE(FunitId)        |      DMI(FunitId)         |       Credit         |    Connectivity         |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(DceIds[i]) begin
  foreach(DmiIds[p]) begin
        $display("|         DCE%0d(%0d)          |       DMI%0d(%0d)             |         %0d          |                         |",i,DceIds[i],p,DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]);
  end
end
        $display("------------------------------------------------------------------------------------------------------");  

endfunction :credit_printer

function void concerto_sw_credit_mgr::set_custom_credit();  // remove from concerto_base_test
    en_credit_alloc = 0;
    foreach(AiuIds[i]) begin
        foreach(DceIds[x]) begin
            if (i == 0) begin //set CAIU0 credit to 10
                test_cfg.aCredit_Cmd[i]["DCE"][DceIds[x]] = 10+1; //+1 due to reserved credit for Wr
            end else if (i == 5) begin
                test_cfg.aCredit_Cmd[i]["DCE"][DceIds[x]] = 4+1;    
            end else  begin //set 4 credit for other IAUs 
                test_cfg.aCredit_Cmd[i]["DCE"][DceIds[x]] = 6+1;   
            end
            `uvm_info("set_custom_credit", $sformatf("AiuIds[%0d] = %0d  DceIds[%0d] = %0d has credit = %0d" ,i,AiuIds[i],x,DceIds[x],test_cfg.aCredit_Cmd[i]["DCE"][DceIds[x]] ), UVM_LOW)
        end
        foreach(DmiIds[x]) begin
            if (i == 0) begin //set CAIU0 credit to 8
                test_cfg.aCredit_Cmd[i]["DMI"][DmiIds[x]] = 8+1;
            end else if (i == 5) begin
                test_cfg.aCredit_Cmd[i]["DMI"][DmiIds[x]] = 4+1;
            end else  begin // set 4 credit for other IAUs 
                test_cfg.aCredit_Cmd[i]["DMI"][DmiIds[x]] = 6+1;   
            end
            `uvm_info("set_custom_credit", $sformatf("AiuIds[%0d] = %0d  DmiIds[%0d] = %0d has credit = %0d" ,i,AiuIds[i],x,DmiIds[x],test_cfg.aCredit_Cmd[i]["DMI"][DmiIds[x]] ), UVM_LOW)
        end
        foreach(DiiIds[x]) begin
            if (i == 4) begin //set CAIU0 credit to 5
                test_cfg.aCredit_Cmd[i]["DII"][DiiIds[x]] = 2+1;
            end else if (i == 5) begin
                test_cfg.aCredit_Cmd[i]["DII"][DiiIds[x]] = 2+1;                
            end else  begin // set 1 credit for other IAUs 
                test_cfg.aCredit_Cmd[i]["DII"][DiiIds[x]] = 5+1;   
            end
            `uvm_info("set_custom_credit", $sformatf("AiuIds[%0d] = %0d  DiiIds[%0d] = %0d has credit = %0d" ,i,AiuIds[i],x,DiiIds[x],test_cfg.aCredit_Cmd[i]["DII"][DiiIds[x]] ), UVM_LOW)
        end
    end

    foreach(DceIds[i]) begin
        foreach(DmiIds[x]) begin
            test_cfg.aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[x]] = 16;
            `uvm_info("set_custom_credit", $sformatf("DceIds[%0d] = %0d  DmiIds[%0d] = %0d has credit = %0d" ,i,DceIds[i],x,DmiIds[x],test_cfg.aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[x]] ), UVM_LOW)
        end
    end
    
   
endfunction
