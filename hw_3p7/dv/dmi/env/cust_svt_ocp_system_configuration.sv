//=======================================================================
// COPYRIGHT (C) 2012 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Class cust_svt_ocp_system_configuration is used to encapsulate the  
 * system configurations for Master and Slave sides of the DUT.
 */

`ifndef GUARD_CUST_SVT_OCP_SYSTEM_CONFIGURATION_SV
`define GUARD_CUST_SVT_OCP_SYSTEM_CONFIGURATION_SV

class cust_svt_ocp_system_configuration extends uvm_object;

  /**
   * System configuration object used by the Monitor VIP on the 
   * Master side of the HDL Interconnect
   */
  svt_ocp_system_configuration vip_ocp_sys_cfg_master;
  
  /**
   * System configuration object used by the Monitor VIP on the 
   * Slave side of the HDL Interconnect
   */
//  svt_ocp_system_configuration vip_ocp_sys_cfg_slave;

  /**
   * UVM object utility macro which implements the create() and get_type_name() methods.
   */
  `uvm_object_utils_begin (cust_svt_ocp_system_configuration)
    `uvm_field_object(vip_ocp_sys_cfg_master, UVM_ALL_ON)
 //   `uvm_field_object(vip_ocp_sys_cfg_slave, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "cust_svt_ocp_system_configuration");
    super.new(name);
      /**
       * Constructing system configuration object used by Monitor VIP, monitoring 
       * the Master side of the HDL Interconnect
       */
      this.vip_ocp_sys_cfg_master = svt_ocp_system_configuration::type_id::create("vip_ocp_sys_cfg_master");
      
      /**
       * Constructing system configuration object used by Monitor VIP, monitoring
       * the Slave side of the HDL Interconnect
       */
  //    this.vip_ocp_sys_cfg_slave = svt_ocp_system_configuration::type_id::create("vip_ocp_sys_cfg_slave");

      /** Initializing the Monitor with the 'inst' and 'stream ID' */
      this.vip_ocp_sys_cfg_master.inst = "env.mon_mstr";

      /** Initializing the Master with the 'inst' and 'stream ID' */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.inst = "env.mstr";

      /** Enabling the debug interface */ 
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_b_use_debug_interface = 1;
      this.vip_ocp_sys_cfg_master.m_n_dataflow_bus_activity_timeout = 32'h7fffffff;
 
      /** Setting is_active bit */      
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.is_active = 1;

      /** Agent ID number setting */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_n_agent_id = 0;
      
      /** Enable dataflow and sideband XML generation */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.enable_df_xml_gen = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.enable_sb_xml_gen = 1;

      /** Enable dataflow reporting and tracing */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.enable_df_reporting = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.enable_df_tracing = 2;
      
      /** Enable mandatory dataflow coverage */
//      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.enable_df_coverage = `SVT_OCP_SYS_ENV_MAN_DF_DEF_COV;

      /** Enabling the memory */ 
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_en_slv_driver_resp = svt_ocp_core_configuration::INTERNAL_MEMORY_RESPONSE;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_en_meminit = svt_mem::ADDRESS;
      
      /** Enabling the MAddr signal and setting the address width to 32 bit */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.addr             = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.addr_wdth        = 32;
      
      /** Enabling only commands (MCmd) of type WR and RD */
      //this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.write_enable     = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.writenonpost_enable    = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.read_enable      = 1;

      /** 
       * Enabling the MData signal into the interface and configuring the width to
       * 32 bit
       */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.mdata           = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.data_wdth       = 32;

      /** Enabling the MDataValid and MRespAccept signals into the interface */
     // this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.datahandshake    = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.respaccept       = 1;

      /** 
       * Enabling the SCmdAcept, SData, SDataAccept and SResp signals into the 
       * interface 
       */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.cmdaccept        = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.sdata            = 1;
     // this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.dataaccept       = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.resp             = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.writeresp_enable = 1;

      /** Enabling the MBurstLength signal into the interface */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.burstlength      = 1;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.burstlength_wdth = 2;
      
      /** Enabling the MReset_n signal into the interface */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.mreset           = 1;

      /** Using default tie-off values for the signals */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_en_default_tie_offs = SVT_DATA_BOOL_TRUE;
      
      /**               
       * When m_en_max_rand_ocp_ver is OCP22WREXT/OCP22/OCP21/OCP20/ m_en_order_consistency_before_ocp30 
       * is valid and is defaulted to ENFORCED indicating a restrictive implementation.
       * When m_en_max_rand_ocp_ver is set to UNLIMITED or a version number beyond OCP22WREXT (eg: OCP30), 
       * m_en_order_consistency_ocp30_and_beyond is valid and is defaulted to IGNORED
       * indicating a relaxed implementation.
       * To achieve full coverage of the verification space, this parameter should be set to IGNORED. 
       */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_en_order_consistency_before_ocp30 = svt_ocp_core_configuration::IGNORED;
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_en_max_rand_ocp_ver = svt_ocp_core_configuration::UNLIMITED;

      /** 
       * Make sure that Slave configuration present in the system configuration
       * also has the same configuration as the Master configuration
       */

      /** Initializing the Slave with the 'inst' and 'stream ID' */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.inst = "env.slv";

      /** Enabling the debug interface */ 
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.m_b_use_debug_interface = 1;
 
      /** Setting is_active bit */      
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.is_active = 1;
      
      /** Enable dataflow and sideband XML generation */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.enable_df_xml_gen = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.enable_sb_xml_gen = 1;

      /** Enable dataflow reporting and tracing */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.enable_df_reporting = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.enable_df_tracing = 2;
      
      /** Enable mandatory dataflow coverage */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.enable_df_coverage = `SVT_OCP_SYS_ENV_MAN_DF_DEF_COV;

      /** Enabling the memory */ 
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.m_en_slv_driver_resp = svt_ocp_core_configuration::INTERNAL_MEMORY_RESPONSE;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.m_en_meminit = svt_mem::ADDRESS;
      
      /** Enabling the MAddr signal and setting the address width to 32 bit */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.addr             = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.addr_wdth        = 32;
      
      /** Enabling only commands (MCmd) of type WR and RD */
      //this.vip_ocp_sys_cfg_master.m_o_slv_cfg.write_enable     = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.writenonpost_enable    = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.read_enable      = 1;

      /** 
       * Enabling the MData signal into the interface and configuring the width to 
       * 32 bit 
       */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.mdata           = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.data_wdth       = 32;

      /** Enabling the MDataValid and MRespAccept signals into the interface */
     // this.vip_ocp_sys_cfg_master.m_o_slv_cfg.datahandshake    = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.respaccept       = 1;

      /** 
       * Enabling the SCmdAcept, SData, SDataAccept and SResp signals into the 
       * interface 
       */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.cmdaccept        = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.sdata            = 1;
    //  this.vip_ocp_sys_cfg_master.m_o_slv_cfg.dataaccept       = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.resp             = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.writeresp_enable = 1;

      /** Enabling the MBurstLength signal into the interface */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.burstlength      = 1;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.burstlength_wdth = 2;

      /** Enabling the MReset_n signal into the interface */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.mreset           = 1;

      /** Using default tie-off values for the signals */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.m_en_default_tie_offs = SVT_DATA_BOOL_TRUE;

      /**               
       * When m_en_max_rand_ocp_ver is OCP22WREXT/OCP22/OCP21/OCP20/ m_en_order_consistency_before_ocp30 
       * is valid and is defaulted to ENFORCED indicating a restrictive implementation.
       * When m_en_max_rand_ocp_ver is set to UNLIMITED or a version number beyond OCP22WREXT (eg: OCP30), 
       * m_en_order_consistency_ocp30_and_beyond is valid and is defaulted to IGNORED
       * indicating a relaxed implementation.
       * To achieve full coverage of the verification space, this parameter should be set to IGNORED. 
       */
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.m_en_order_consistency_before_ocp30 = svt_ocp_core_configuration::IGNORED;
      this.vip_ocp_sys_cfg_master.m_o_slv_cfg.m_en_max_rand_ocp_ver = svt_ocp_core_configuration::UNLIMITED;

    //  /** Initializing the Slave with the 'inst' and 'stream ID" */
    //  this.vip_ocp_sys_cfg_slave.inst = "env.mon_slv";

    //  /** Initializing the Slave with the 'inst' and 'stream ID' */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.inst = "env.slv";
    //  
    //  /** Enabling the debug interface */ 
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_b_use_debug_interface = 1;
 
    //  /** Setting is_active bit */      
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.is_active = 1;
    //    		
    //  /** Agent ID number setting */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_n_agent_id = 0;
    //  
    //  /** Enable dataflow and sideband XML generation */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.enable_df_xml_gen = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.enable_sb_xml_gen = 1;

    //  /** Enable dataflow reporting and tracing */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.enable_df_reporting = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.enable_df_tracing = 2;
    //  
    //  /** Enable mandatory dataflow coverage */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.enable_df_coverage = `SVT_OCP_SYS_ENV_MAN_DF_DEF_COV;

    //  /** Enabling the memory */ 
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_en_slv_driver_resp = svt_ocp_core_configuration::INTERNAL_MEMORY_RESPONSE;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_en_meminit = svt_mem::ADDRESS;
    //  
    //  /** Enabling the MAddr signal and setting the address width to 32 bit */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.addr             = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.addr_wdth        = 32;
    //  
    //  /** Enabling only commands (MCmd) of type WR and RD */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.write_enable     = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.read_enable      = 1;

    //  /** 
    //   * Enabling the MData signal into the interface and configuring the width to 
    //   * 32 bit 
    //   */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.mdata           = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.data_wdth       = 32;

    //  /** Enabling the MDataValid and MRespAccept signals into the interface */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.datahandshake    = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.respaccept       = 1;

    //  /** 
    //   * Enabling the SCmdAcept, SData, SDataAccept and SResp signals into the 
    //   * interface 
    //   */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.cmdaccept        = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.sdata            = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.dataaccept       = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.resp             = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.writeresp_enable = 1;

    //  /** Enabling the MBurstLength signal into the interface */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.burstlength      = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.burstlength_wdth = 2;

    //  /** Enabling the MReset_n signal into the interface */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.mreset           = 1;

    //  /** Using default tie-off values for the signals */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_en_default_tie_offs = SVT_DATA_BOOL_TRUE;

    //  /**               
    //   * When m_en_max_rand_ocp_ver is OCP22WREXT/OCP22/OCP21/OCP20/ m_en_order_consistency_before_ocp30 
    //   * is valid and is defaulted to ENFORCED indicating a restrictive implementation.
    //   * When m_en_max_rand_ocp_ver is set to UNLIMITED or a version number beyond OCP22WREXT (eg: OCP30), 
    //   * m_en_order_consistency_ocp30_and_beyond is valid and is defaulted to IGNORED
    //   * indicating a relaxed implementation.
    //   * To achieve full coverage of the verification space, this parameter should be set to IGNORED. 
    //   */
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_en_order_consistency_before_ocp30 = svt_ocp_core_configuration::IGNORED;
    //  this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_en_max_rand_ocp_ver = svt_ocp_core_configuration::UNLIMITED;

    //  /**
    //   * Make sure that Master configuration present in the system configuration also 
    //   * has the same configuration as the Master configuration
    //   */

    //  /** Initializing the Master with the 'inst' and 'stream ID' */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.inst = "env.mstr";
    //  
    //  /** Enabling the debug interface */ 
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.m_b_use_debug_interface = 1;
 
    //  /** Setting is_active bit */      
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.is_active = 1;
    //  
    //  /** Enable dataflow and sideband XML generation */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.enable_df_xml_gen = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.enable_sb_xml_gen = 1;

    //  /** Enable dataflow reporting and tracing */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.enable_df_reporting = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.enable_df_tracing = 2;
    //  
    //  /** Enable mandatory dataflow coverage */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.enable_df_coverage = `SVT_OCP_SYS_ENV_MAN_DF_DEF_COV;

    //  /** Enabling the memory */ 
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.m_en_slv_driver_resp = svt_ocp_core_configuration::INTERNAL_MEMORY_RESPONSE;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.m_en_meminit = svt_mem::ADDRESS;

    //  /** Enabling the MAddr signal and setting the address width to 32 bit */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.addr             = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.addr_wdth        = 32;
    //  
    //  /** Enabling only commands (MCmd) of type WR and RD */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.write_enable     = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.read_enable      = 1;

    //  /** 
    //   * Enabling the MData signal into the interface and configuring the width to 
    //   * 32 bit 
    //   */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.mdata           = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.data_wdth       = 32;

    //  /** Enabling the MDataValid and MRespAccept signals into the interface */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.datahandshake    = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.respaccept       = 1;

    //  /** 
    //   * Enabling the SCmdAcept, SData, SDataAccept and SResp signals into the 
    //   * interface 
    //   */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.cmdaccept        = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.sdata            = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.dataaccept       = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.resp             = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.writeresp_enable = 1;

    //  /** Enabling the MBurstLength signal into the interface */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.burstlength      = 1;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.burstlength_wdth = 2;

    //  /** Enabling the MReset_n signal into the interface */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.mreset           = 1;

    //  /** Using default tie-off values for the signals */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.m_en_default_tie_offs = SVT_DATA_BOOL_TRUE;

    //  /**               
    //   * When m_en_max_rand_ocp_ver is OCP22WREXT/OCP22/OCP21/OCP20/ m_en_order_consistency_before_ocp30 
    //   * is valid and is defaulted to ENFORCED indicating a restrictive implementation.
    //   * When m_en_max_rand_ocp_ver is set to UNLIMITED or a version number beyond OCP22WREXT (eg: OCP30), 
    //   * m_en_order_consistency_ocp30_and_beyond is valid and is defaulted to IGNORED
    //   * indicating a relaxed implementation.
    //   * To achieve full coverage of the verification space, this parameter should be set to IGNORED. 
    //   */
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.m_en_order_consistency_before_ocp30 = svt_ocp_core_configuration::IGNORED;
    //  this.vip_ocp_sys_cfg_slave.m_o_mstr_cfg.m_en_max_rand_ocp_ver = svt_ocp_core_configuration::UNLIMITED;

      /**
       * Assigning the system configuration handle present in the master and slave
       * configuration object to the system configuration
       */
      this.vip_ocp_sys_cfg_master.m_o_mstr_cfg.m_o_sys_cfg = vip_ocp_sys_cfg_master;
   //   this.vip_ocp_sys_cfg_slave.m_o_slv_cfg.m_o_sys_cfg = vip_ocp_sys_cfg_slave;
      
  endfunction : new   
    
endclass : cust_svt_ocp_system_configuration
`endif //GUARD_CUST_SVT_OCP_SYSTEM_CONFIGURATION_SV
