<%if(obj.useResiliency == 1 || obj.DebugApbInfo.length > 0){%>
// ****************************************************************************
// Class : cdnApbUvmActiveMasterAgent
// Desc. : This class is used as a basis apb Active Master. 
// ****************************************************************************
class cdnApbUvmActiveMasterAgent_fsc extends cdnApbUvmAgent;

  `uvm_component_utils_begin(cdnApbUvmActiveMasterAgent_fsc)        
  `uvm_component_utils_end
    
<%if(obj.useResiliency == 1 ){%>
 `cdnApbDeclareVif(virtual interface cdnApb4ActiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wData%>)))
<% } %>

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "cdnApbUvmActiveMasterAgent_fsc", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase  

endclass : cdnApbUvmActiveMasterAgent_fsc

class cdnApbUvmActiveMasterAgent_apb extends cdnApbUvmAgent;

  `uvm_component_utils_begin(cdnApbUvmActiveMasterAgent_apb)        
  `uvm_component_utils_end
    
 `cdnApbDeclareVif(virtual interface cdnApb4ActiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>)))
 
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "cdnApbUvmActiveMasterAgent_apb", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase  

endclass : cdnApbUvmActiveMasterAgent_apb

// ****************************************************************************
// Class : cdnApbUvmPassiveMasterAgent
// Desc. : This class is used as a basis apb Active Master. 
// ****************************************************************************
class cdnApbUvmPassiveMasterAgent_fsc extends cdnApbUvmAgent;

  `uvm_component_utils_begin(cdnApbUvmPassiveMasterAgent_fsc)        
  `uvm_component_utils_end
    
<%if(obj.useResiliency == 1 ){%>
 `cdnApbDeclareVif(virtual interface cdnApb4PassiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wData%>)))
<% } %>

 
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "cdnApbUvmPassiveMasterAgent_fsc", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase  

endclass : cdnApbUvmPassiveMasterAgent_fsc

class cdnApbUvmPassiveMasterAgent_apb extends cdnApbUvmAgent;

  `uvm_component_utils_begin(cdnApbUvmPassiveMasterAgent_apb)        
  `uvm_component_utils_end
    

 `cdnApbDeclareVif(virtual interface cdnApb4PassiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>)))
 
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "cdnApbUvmPassiveMasterAgent_apb", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase  

endclass : cdnApbUvmPassiveMasterAgent_apb
// ****************************************************************************
// Class : cdnApbUvmActiveSlaveAgent
// Desc. : This class is used as a basis apb Slave. 
// ****************************************************************************
class cdnApbUvmActiveSlaveAgent extends cdnApbUvmAgent;

  `uvm_component_utils_begin(cdnApbUvmActiveSlaveAgent)        
  `uvm_component_utils_end
    
<%if(obj.useResiliency == 1 ){%>
 `cdnApbDeclareVif(virtual interface cdnApb4ActiveSlaveInterface#(
                     .ADDRESS_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wData%>)))
<% } %>

// `cdnApbDeclareVif(virtual interface cdnApb4ActiveSlaveInterface#(
  //                   .ADDRESS_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>),
    //                 .DATA_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>)))
 
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "cdnApbUvmActiveSlaveAgent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase  

endclass : cdnApbUvmActiveSlaveAgent
<% } %>


<% cnt = 0; %>
<% obj.AiuInfo.forEach(function(bundle, indx) { %>
<%   if(bundle.fnNativeInterface === 'ACE' || bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === 'AXI4' || bundle.fnNativeInterface === "ACELITE-E" || bundle.fnNativeInterface === 'AXI5' || bundle.fnNativeInterface === 'ACE5' ) {
          for (var mpu_io = 0; mpu_io < bundle.nNativeInterfacePorts; mpu_io++){
       var userMax = Math.max(bundle.interfaces.axiInt[mpu_io].params.wAwUser, 
        			bundle.interfaces.axiInt[mpu_io].params.wArUser,
        			bundle.interfaces.axiInt[mpu_io].params.wWUser,
        			bundle.interfaces.axiInt[mpu_io].params.wBUser,
        			bundle.interfaces.axiInt[mpu_io].params.wRUser);
       var wAxId   = Math.max(bundle.interfaces.axiInt[mpu_io].params.wArId,bundle.interfaces.axiInt[mpu_io].params.wAwId); 
       var wAxAddr = bundle.interfaces.axiInt[mpu_io].params.wAddr;
       var wXData  = bundle.interfaces.axiInt[mpu_io].params.wData;
%>
class activeMasterAgent<%=cnt%> extends cdnAxiUvmAgent;
  
  integer CacheLineSize; // cache line size 

  `uvm_component_utils_begin(activeMasterAgent<%=cnt%>)        
  `uvm_component_utils_end

<%    if(bundle.fnNativeInterface === 'ACE') { %>  

 `cdnAxiDeclareVif(virtual interface cdnAceFullActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'ACE5' ) { %>
 `cdnAxiDeclareVif(virtual interface cdnAce5FullActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))

<% }  else  if((bundle.fnNativeInterface === "ACELITE-E") && (bundle.interfaces.axiInt[mpu_io].params.eAc > 0)) { %>
 `cdnAxiDeclareVif(virtual interface cdnAce5LiteDvmActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                             .ADDR_WIDTH(<%=wAxAddr%>),
                                                             .DATA_WIDTH(<%=wXData%>),
                                                             .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'ACELITE-E' ) { %>

 `cdnAxiDeclareVif(virtual interface cdnAce5LiteActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                           .ADDR_WIDTH(<%=wAxAddr%>),
                                                           .DATA_WIDTH(<%=wXData%>),
                                                           .USER_WIDTH(<%=userMax%>)))
<% }  else  if((bundle.fnNativeInterface === "ACE-LITE") && (bundle.interfaces.axiInt[mpu_io].params.eAc > 0)) { %>
 `cdnAxiDeclareVif(virtual interface cdnAceLiteDvmActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                             .ADDR_WIDTH(<%=wAxAddr%>),
                                                             .DATA_WIDTH(<%=wXData%>),
                                                             .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'ACE-LITE' ) { %>

 `cdnAxiDeclareVif(virtual interface cdnAceLiteActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'AXI4' ) { %>
 `cdnAxiDeclareVif(virtual interface cdnAxi4ActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'AXI5' ) { %>
 `cdnAxiDeclareVif(virtual interface cdnAxi5ActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } %>


  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "activeMasterAgent<%=cnt%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  // ***************************************************************
  // Method : end_of_elaboration_phase
  // Desc.  : Apply configuration settings in this phase
  // ***************************************************************
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if(denaliMemGetSomaValueInt(inst.instName,"cache_line_size",CacheLineSize) == DENALIerror_NoError)
    	`uvm_info(get_type_name(), $psprintf("CacheLineSize = %0d",CacheLineSize), UVM_LOW)
    else
    	`uvm_fatal(get_type_name(), $psprintf("Couldn't get CacheLineSize = %0d from soma file",CacheLineSize))   
  endfunction

  /////////////////////////////////////////////////////////////
  //  			Cache handling functions
  /////////////////////////////////////////////////////////////
  function void userWriteCacheEntry(reg [63:0] Address, reg [7:0] Data [], reg [7:0] state,
  	denaliCdn_axiSecureModeT secureMode = DENALI_CDN_AXI_SECUREMODE_SECURE); 
    reg [7:0] data_tmp [];
    data_tmp = new[Data.size()+1]; // cache line size in bytes + 1
    data_tmp[0] = state; 
    for (int i=1; i<data_tmp.size(); i++) begin 
      data_tmp[i]=Data[i-1];
    end
    
    // In case the secure bit defines two separate memory segments, 
    // the user will need to specify the secure nature of the back-door access.
    regInst.writeReg( DENALI_CDN_AXI_REG_BackdoorAccessSecureMode, secureMode);
    
    aceCacheInst.writeMem(Address / CacheLineSize ,data_tmp); 
  endfunction 
            
  virtual function void userReadCacheEntry( reg [63:0] Address, ref reg [7:0] Data [], ref reg [7:0] state,
  	input denaliCdn_axiSecureModeT secureMode = DENALI_CDN_AXI_SECUREMODE_SECURE);
    reg [7:0] data_tmp [];
    data_tmp = new[Data.size()+1]; // cache line size in bytes + 1  
    
    // In case the secure bit defines two separate memory segments, 
    // the user will need to specify the secure nature of the back-door access.
    regInst.writeReg( DENALI_CDN_AXI_REG_BackdoorAccessSecureMode, secureMode);
              	                                                
    aceCacheInst.readMem(Address / CacheLineSize, data_tmp); 
    for (int i=1; i<data_tmp.size(); i++) begin
      Data[i-1] = data_tmp[i];
    end
    state = data_tmp[0]; 
  endfunction 

  virtual function reg [7:0] getCacheLineState( reg [63:0] Address, denaliCdn_axiSecureModeT secureMode = DENALI_CDN_AXI_SECUREMODE_SECURE );
    reg [7:0] data [];
    reg [7:0] state;
    state = 0;
    data = new[CacheLineSize]; 
    userReadCacheEntry(Address, data, state, secureMode); 
    return state; 
  endfunction
endclass : activeMasterAgent<%=cnt%>

class passiveMasterAgent<%=cnt%> extends cdnAxiUvmAgent;
  
  integer CacheLineSize; // cache line size 

  `uvm_component_utils_begin(passiveMasterAgent<%=cnt%>)        
  `uvm_component_utils_end

<%    if(bundle.fnNativeInterface === 'ACE') { %>  

 `cdnAxiDeclareVif(virtual interface cdnAceFullPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'ACE5' ) { %>
 `cdnAxiDeclareVif(virtual interface cdnAce5FullPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))

<% }  else  if((bundle.fnNativeInterface === "ACELITE-E") && (bundle.interfaces.axiInt[mpu_io].params.eAc > 0)) { %>
 `cdnAxiDeclareVif(virtual interface cdnAce5LiteDvmPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                             .ADDR_WIDTH(<%=wAxAddr%>),
                                                             .DATA_WIDTH(<%=wXData%>),
                                                             .USER_WIDTH(<%=userMax%>)))
<%    } else if(bundle.fnNativeInterface === 'ACELITE-E' ) { %>

 `cdnAxiDeclareVif(virtual interface cdnAce5LitePassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                           .ADDR_WIDTH(<%=wAxAddr%>),
                                                           .DATA_WIDTH(<%=wXData%>),
                                                           .USER_WIDTH(<%=userMax%>)))
<% }  else  if((bundle.fnNativeInterface === "ACE-LITE") && (bundle.interfaces.axiInt[mpu_io].params.eAc > 0)) { %>
 `cdnAxiDeclareVif(virtual interface cdnAceLiteDvmPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                             .ADDR_WIDTH(<%=wAxAddr%>),
                                                             .DATA_WIDTH(<%=wXData%>),
                                                             .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'ACE-LITE' ) { %>

 `cdnAxiDeclareVif(virtual interface cdnAceLitePassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'AXI4' ) { %>
 `cdnAxiDeclareVif(virtual interface cdnAxi4PassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } else if(bundle.fnNativeInterface === 'AXI5' ) { %>
 `cdnAxiDeclareVif(virtual interface cdnAxi5PassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                                                          .ADDR_WIDTH(<%=wAxAddr%>),
                                                          .DATA_WIDTH(<%=wXData%>),
                                                          .USER_WIDTH(<%=userMax%>)))
<% } %>


  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "passiveMasterAgent<%=cnt%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

  // ***************************************************************
  // Method : end_of_elaboration_phase
  // Desc.  : Apply configuration settings in this phase
  // ***************************************************************
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    monitor.set_report_severity_id_action(UVM_FATAL, "CDN_AXI_FATAL_ERR_VR_AXI226_MEMORY_INCONSISTENCY",UVM_NO_ACTION);
    if(denaliMemGetSomaValueInt(inst.instName,"cache_line_size",CacheLineSize) == DENALIerror_NoError)
    	`uvm_info(get_type_name(), $psprintf("CacheLineSize = %0d",CacheLineSize), UVM_LOW)
    else
    	`uvm_fatal(get_type_name(), $psprintf("Couldn't get CacheLineSize = %0d from soma file",CacheLineSize))   
  endfunction

  /////////////////////////////////////////////////////////////
  //  			Cache handling functions
  /////////////////////////////////////////////////////////////
  function void userWriteCacheEntry(reg [63:0] Address, reg [7:0] Data [], reg [7:0] state,
  	denaliCdn_axiSecureModeT secureMode = DENALI_CDN_AXI_SECUREMODE_SECURE); 
    reg [7:0] data_tmp [];
    data_tmp = new[Data.size()+1]; // cache line size in bytes + 1
    data_tmp[0] = state; 
    for (int i=1; i<data_tmp.size(); i++) begin 
      data_tmp[i]=Data[i-1];
    end
    
    // In case the secure bit defines two separate memory segments, 
    // the user will need to specify the secure nature of the back-door access.
    regInst.writeReg( DENALI_CDN_AXI_REG_BackdoorAccessSecureMode, secureMode);
    
    aceCacheInst.writeMem(Address / CacheLineSize ,data_tmp); 
  endfunction 
            
  virtual function void userReadCacheEntry( reg [63:0] Address, ref reg [7:0] Data [], ref reg [7:0] state,
  	input denaliCdn_axiSecureModeT secureMode = DENALI_CDN_AXI_SECUREMODE_SECURE);
    reg [7:0] data_tmp [];
    data_tmp = new[Data.size()+1]; // cache line size in bytes + 1  
    
    // In case the secure bit defines two separate memory segments, 
    // the user will need to specify the secure nature of the back-door access.
    regInst.writeReg( DENALI_CDN_AXI_REG_BackdoorAccessSecureMode, secureMode);
              	                                                
    aceCacheInst.readMem(Address / CacheLineSize, data_tmp); 
    for (int i=1; i<data_tmp.size(); i++) begin
      Data[i-1] = data_tmp[i];
    end
    state = data_tmp[0]; 
  endfunction 

  virtual function reg [7:0] getCacheLineState( reg [63:0] Address, denaliCdn_axiSecureModeT secureMode = DENALI_CDN_AXI_SECUREMODE_SECURE );
    reg [7:0] data [];
    reg [7:0] state;
    state = 0;
    data = new[CacheLineSize]; 
    userReadCacheEntry(Address, data, state, secureMode); 
    return state; 
  endfunction
endclass : passiveMasterAgent<%=cnt%>

<% cnt++ } }%>
<% }); %>



<% 
/*Assignments*/
cnt = 0;
var userMax   = 0;
obj.DmiInfo.forEach(function(e, i, array) {
    var userMax = Math.max(e.interfaces.axiInt.params.wAwUser, 
                           e.interfaces.axiInt.params.wArUser,
                           e.interfaces.axiInt.params.wWUser,
                           e.interfaces.axiInt.params.wBUser,
                           e.interfaces.axiInt.params.wRUser);

     var wAxId   = Math.max(e.interfaces.axiInt.params.wAwId,e.interfaces.axiInt.params.wArId);
     var wAxAddr = e.interfaces.axiInt.params.wAddr;
     var wXData  = e.interfaces.axiInt.params.wData;
%>
class dmiactiveSlaveAgent<%=cnt%> extends cdnAxiUvmAgent;
  
  `uvm_component_utils_begin(dmiactiveSlaveAgent<%=cnt%>)        
  `uvm_component_utils_end

<%  if(e.fnNativeInterface === "AXI" || e.fnNativeInterface === "AXI4") { %> 
 `cdnAxiDeclareVif(virtual interface cdnAxi4ActiveSlaveInterface#(
                       .DATA_WIDTH(<%=wXData%>),
                       .ADDR_WIDTH(<%=wAxAddr %>),
                       .READ_ID_WIDTH(<%=obj.DmiInfo[cnt].interfaces.axiInt.params.wArId%>),
                       .WRITE_ID_WIDTH(<%=obj.DmiInfo[cnt].interfaces.axiInt.params.wAwId%>),
                       .USER_WIDTH(<%=userMax%>)))

<%  } else { %>
    var err = "Unexpected Native interface type. expected (AXI)";
    throw err;
<% } %>
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "dmiactiveSlaveAgent<%=cnt%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new      

endclass: dmiactiveSlaveAgent<%=cnt%>

class dmipassiveSlaveAgent<%=cnt%> extends cdnAxiUvmAgent;
  
  `uvm_component_utils_begin(dmipassiveSlaveAgent<%=cnt%>)        
  `uvm_component_utils_end

<%  if(e.fnNativeInterface === "AXI" || e.fnNativeInterface === "AXI4") { %> 
 `cdnAxiDeclareVif(virtual interface cdnAxi4PassiveInterface#(
                       .DATA_WIDTH(<%=wXData%>),
                       .ADDR_WIDTH(<%=wAxAddr %>),
                       .READ_ID_WIDTH(<%=obj.DmiInfo[cnt].interfaces.axiInt.params.wArId%>),
                       .WRITE_ID_WIDTH(<%=obj.DmiInfo[cnt].interfaces.axiInt.params.wAwId%>),
                       .USER_WIDTH(<%=userMax%>)))

<%  } else { %>
    var err = "Unexpected Native interface type. expected (AXI)";
    throw err;
<% } %>
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "dmipassiveSlaveAgent<%=cnt%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new      

endclass: dmipassiveSlaveAgent<%=cnt%>

<%      
        cnt++;
}); %>

<% 
/*Assignments*/
cnt = 0;
var userMax   = 0;
obj.DiiInfo.forEach(function(e, i, array) {
    var userMax = Math.max(e.interfaces.axiInt.params.wAwUser, 
                           e.interfaces.axiInt.params.wArUser,
                           e.interfaces.axiInt.params.wWUser,
                           e.interfaces.axiInt.params.wBUser,
                           e.interfaces.axiInt.params.wRUser);

     var wAxId   = Math.max(e.interfaces.axiInt.params.wAwId,e.interfaces.axiInt.params.wArId);
     var wAxAddr = e.interfaces.axiInt.params.wAddr;
     var wXData  = e.interfaces.axiInt.params.wData;
%>
<% if(e.configuration == 0) {%>
class diiactiveSlaveAgent<%=cnt%> extends cdnAxiUvmAgent;
  
  `uvm_component_utils_begin(diiactiveSlaveAgent<%=cnt%>)        
  `uvm_component_utils_end

<%  if(e.fnNativeInterface === "AXI" || e.fnNativeInterface === "AXI4") { %> 
 `cdnAxiDeclareVif(virtual interface cdnAxi4ActiveSlaveInterface#(
                       .DATA_WIDTH(<%=wXData%>),
                       .ADDR_WIDTH(<%=wAxAddr %>),
                       .ID_WIDTH(<%=wAxId%>),
                       .USER_WIDTH(<%=userMax%>)))

<%  } else { %>
    var err = "Unexpected Native interface type. expected (AXI)";
    throw err;
<% } %>
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "diiactiveSlaveAgent<%=cnt%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new      

endclass: diiactiveSlaveAgent<%=cnt%>

class diipassiveSlaveAgent<%=cnt%> extends cdnAxiUvmAgent;
  
  `uvm_component_utils_begin(diipassiveSlaveAgent<%=cnt%>)        
  `uvm_component_utils_end

<%  if(e.fnNativeInterface === "AXI" || e.fnNativeInterface === "AXI4") { %> 
 `cdnAxiDeclareVif(virtual interface cdnAxi4PassiveInterface#(
                       .DATA_WIDTH(<%=wXData%>),
                       .ADDR_WIDTH(<%=wAxAddr %>),
                       .ID_WIDTH(<%=wAxId%>),
                       .USER_WIDTH(<%=userMax%>)))

<%  } else { %>
    var err = "Unexpected Native interface type. expected (AXI)";
    throw err;
<% } %>
  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "diipassiveSlaveAgent<%=cnt%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new      

endclass: diipassiveSlaveAgent<%=cnt%>

<%      
        cnt++;
}}); %>


