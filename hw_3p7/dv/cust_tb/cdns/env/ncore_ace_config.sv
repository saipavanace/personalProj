// ****************************************************************************
// Class : aceFullUvmUserConfig
// Desc. : This class can be created by newPureview or manually by customer
// ****************************************************************************
class aceFullUvmUserConfig extends cdnAxiUvmConfig;
    
  `uvm_object_utils_begin(aceFullUvmUserConfig)  
  `uvm_object_utils_end
  
  function new(string name = "aceFullUvmUserConfig");
    super.new(name);
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_FULL;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_ACE;
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA4;    
  endfunction : new       
  
endclass

class ace5LiteUvmUserConfig extends cdnAxiUvmConfig;
    
  `uvm_object_utils_begin(ace5LiteUvmUserConfig)  
  `uvm_object_utils_end
  
  function new(string name = "ace5LiteUvmUserConfig");
    super.new(name);
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_LITE;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_ACE;
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA5;    
  endfunction : new       
  
endclass

class aceLiteUvmUserConfig extends cdnAxiUvmConfig;
    
  `uvm_object_utils_begin(aceLiteUvmUserConfig)  

  `uvm_object_utils_end
  
  function new(string name = "aceLiteUvmUserConfig");
    super.new(name);
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_LITE;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_ACE;
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA4;    
  endfunction : new       
  
endclass

class axi4UvmUserConfig extends cdnAxiUvmConfig;
    
  `uvm_object_utils_begin(axi4UvmUserConfig)  

  `uvm_object_utils_end
  
  function new(string name = "axi4UvmUserConfig");
    super.new(name);
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_FULL;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_BASE;
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA4;    
  endfunction : new       
  
endclass
class axiSlaveUvmUserConfig extends cdnAxiUvmConfig;

    `uvm_object_utils_begin(axiSlaveUvmUserConfig)
    `uvm_object_utils_end

    function new(string name = "axiSlaveUvmUserConfig");
        super.new(name);

        spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_FULL;
        spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_BASE;
        spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA4;    
    endfunction: new

endclass: axiSlaveUvmUserConfig

class ace5FullUvmUserConfig extends cdnAxiUvmConfig;
    
  `uvm_object_utils_begin(ace5FullUvmUserConfig)  
  `uvm_object_utils_end
  
  function new(string name = "ace5FullUvmUserConfig");
    super.new(name);

    // set feature values
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_FULL;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_ACE;
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA5;    
  endfunction : new       
  
endclass

class axi5UvmUserConfig extends cdnAxiUvmConfig;
    
  `uvm_object_utils_begin(axi5UvmUserConfig)  
  `uvm_object_utils_end
  
  function new(string name = "axi5UvmUserConfig");
    super.new(name);

    // set feature values
    spec_ver = CDN_AXI_CFG_SPEC_VER_AMBA5;
    spec_subtype = CDN_AXI_CFG_SPEC_SUBTYPE_BASE;
    spec_interface = CDN_AXI_CFG_SPEC_INTERFACE_FULL;  
  endfunction : new    
  
endclass
