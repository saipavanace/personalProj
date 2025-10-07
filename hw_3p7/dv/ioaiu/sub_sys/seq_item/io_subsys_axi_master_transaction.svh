`ifndef GUARD_IO_SUBSYS_AXI_MASTER_TRANSACTION_SVH
`define GUARD_IO_SUBSYS_AXI_MASTER_TRANSACTION_SVH 
class io_subsys_axi_master_transaction extends svt_axi_master_transaction; 
bit dvm_test = 0;
rand int axi4_nonshareable_addr_range_index, axi4_innershareable_addr_range_index; 
rand bit local_axi4_addr_region_pick_ctl;
rand int idx;
bit match = 0;
int core;
int mp_aiu_pri_bitsq[$];
bit [`SVT_AXI_ADDR_WIDTH-1:0] addr_mask;
rand bit [`SVT_AXI_ADDR_WIDTH-1:0] end_addr;
int axcache_alloc_wt;
int axid_collision,nomultiline;
bit en_all_axlen_for_noncoh_txns=0;
bit en_127_255_axlen_for_noncoh_txns=0;
bit reduce_addr_area = 0;
bit use_user_noncoh_addrq = 0;
bit max_id=0;
bit max_data=0;
bit dev_nonbuf=0;
bit nor_mem=0;
string native_intf_delay="";
bit ioc_tgt = 0;
bit ace_tgt = 0;
bit chi_tgt = 0;
string arg_value;
string burst_len;
bit[5:0] awatop;
bit[3:0] axsnoop;
string inject_parity_err_aw_chnl="",inject_parity_err_ar_chnl="",inject_parity_err_w_chnl="";
int data_before_addr_for_wr;
uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
bit restrict_addr_to_specific_domain=0;
bit addr_in_dii=1;
bit addr_in_dmi_nc=1;
bit addr_in_dmi_c=1;
bit [2:0] sel_mem_region;
rand int addr_in_dii_idx;
rand int addr_in_dmi_nc_idx;
rand int addr_in_dmi_c_idx;
bit excl_access_en;
int exclusive_weight;
bit[1:0] ptl_wstrb =0;
bit zero_wstrb =0;
<% if(obj.testBench == "fsys") { %>
static int io_subsys_axi_intf_parity_err_count[addrMgrConst::NUM_IO_MASTERS];
static bit io_subsys_axi_dis_inject_intf_parity_err[addrMgrConst::NUM_IO_MASTERS]='{default:1}; // '{{ 4'h0 }}
<% } %>

`undef CLASS_CONTRAINTS_PREFIX
`define CLASS_CONTRAINTS_PREFIX c_io_subsys_axi_master_transaction

    `svt_xvm_object_utils(io_subsys_axi_master_transaction)
    
    constraint c_multicore_addr {
       if(core >= 0) {
           foreach(mp_aiu_pri_bitsq[i]) {
               addr[mp_aiu_pri_bitsq[i]] == core[i];
            }
           (((addr & addr_mask) >> burst_size) << burst_size) + (burst_length << burst_size) <= (1 << mp_aiu_pri_bitsq[0]);
       } 
    }
    //CONC-17196
    constraint c_stash {
      if(port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE && port_cfg.ace_version == svt_axi_port_configuration::ACE_VERSION_2_0) {
          stash_nid_valid dist {1:=90,0:=10};
      }
    }
    constraint  c_no_nrs_addr_after_boot  {
        if (svt_axi_item_helper::disable_boot_addr_region) {
            !(addr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1)]});
        } else { // if (svt_axi_item_helper::disable_boot_addr_region)
            (addr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1)]});
        } // if (svt_axi_item_helper::disable_boot_addr_region) ... else
    }
   
     constraint c_atomic_cach {
        if(xact_type == ATOMIC) {cache_type[3:2] !=0;
                                 cache_type[1] ==1;
    } else if (nor_mem) {

                                 cache_type[1] ==1;
    }
    
    }


    constraint c_check {
        if(max_data==1){
           foreach(svt_axi_transaction::data[0][i]) {
             svt_axi_transaction::data[0][i] == 'h1;
            }
    } } 

      // Ncore doesnt not support big endian access
    constraint c_endianess_is_little {
        endian == LITTLE_ENDIAN;
    }

    // Ncore doesnt support ATOMICS to DII
    constraint c_no_atomics_to_dii {
        foreach(addrMgrConst::memregions_info[region]) {
            (
                addrMgrConst::memregions_info[region].hut == addrMgrConst::DII
                && (addr >= addrMgrConst::memregions_info[region].start_addr)
                && (addr <= addrMgrConst::memregions_info[region].end_addr)
            ) -> !( xact_type == svt_axi_transaction::ATOMIC);
        }
    }

    //atomic_addrq is a queue of 100/memregion useAtomic=1 DMI addresses created in addr_trans_mgr
    constraint c_no_atomics_to_dmi_with_no_support {
       (xact_type == ATOMIC) -> (addr[addrMgrConst::ADDR_WIDTH-1:addrMgrConst::WCACHE_OFFSET] inside {addrMgrConst::atomic_addrq});
       //solve xact_type before addr;
    }
   
    constraint  c_fixed_burst_not_supported_by_ncore3_x {
        (burst_type != FIXED);
        (addrMgrConst::io_subsys_owo_en[port_id] == 1 && xact_type != ATOMIC) -> (burst_type == INCR);
    }
    
    constraint  c_axi4_noncoh_excl_only {
        if (port_cfg.axi_interface_type inside{svt_axi_port_configuration::AXI4,svt_axi_port_configuration::ACE_LITE}) {
            foreach(addrMgrConst::dmi_memory_coh_domain_start_addr[i]) {
                (addr inside {[addrMgrConst::dmi_memory_coh_domain_start_addr[i] : addrMgrConst::dmi_memory_coh_domain_end_addr[i]]}) -> (atomic_type == NORMAL);
            }

        }

    }
    constraint excl_en {
			if(excl_access_en && port_cfg.axi_interface_type != svt_axi_port_configuration::AXI4 && (coherent_xact_type inside {READNOSNOOP,WRITENOSNOOP})){
				atomic_type dist {EXCLUSIVE := exclusive_weight,NORMAL:=(100-exclusive_weight)};
			}
		}

    //CONC-14376
    constraint c_stash_invalid_nonsharable { 
       if(port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE && port_cfg.ace_version == svt_axi_port_configuration::ACE_VERSION_2_0) {
        if (coherent_xact_type inside{STASHONCESHARED,STASHONCEUNIQUE}) {
            (domain_type != NONSHAREABLE);
        }
    }
    }

    constraint c_domain_type { 
       if(port_cfg.axi_interface_type != svt_axi_port_configuration::AXI4) {
            foreach(addrMgrConst::dmi_memory_coh_domain_start_addr[i]) {
                (addr inside {[addrMgrConst::dmi_memory_coh_domain_start_addr[i] : addrMgrConst::dmi_memory_coh_domain_end_addr[i]]}) -> (domain_type inside {INNERSHAREABLE, OUTERSHAREABLE});
            }
            foreach(addrMgrConst::dmi_memory_noncoh_domain_start_addr[i]) {
                (addr inside {[addrMgrConst::dmi_memory_noncoh_domain_start_addr[i] : addrMgrConst::dmi_memory_noncoh_domain_end_addr[i]]}) -> (domain_type inside {NONSHAREABLE, SYSTEMSHAREABLE});
            }
            foreach(addrMgrConst::dii_memory_domain_start_addr[i]) {
                (addr inside {[addrMgrConst::dii_memory_domain_start_addr[i] : addrMgrConst::dii_memory_domain_end_addr[i]]}) -> (domain_type inside {NONSHAREABLE, SYSTEMSHAREABLE});
            }
        }
    }

    constraint c_restrict_addr_to_specific_domain{ 
            if(restrict_addr_to_specific_domain==1) {
                if((addrMgrConst::dii_memory_domain_start_addr.size() > 0) && (addr_in_dii==1)) {
                    addr_in_dii_idx < addrMgrConst::dii_memory_domain_start_addr.size();
                } else {
                    addr_in_dii_idx == -1;
                }
                if((addrMgrConst::dmi_memory_noncoh_domain_start_addr.size() > 0) && (addr_in_dmi_nc==1)) {
                    addr_in_dmi_nc_idx < addrMgrConst::dmi_memory_noncoh_domain_start_addr.size();
                } else {
                    addr_in_dmi_nc_idx == -1;
                }
                if((addrMgrConst::dmi_memory_coh_domain_start_addr.size() > 0) && (addr_in_dmi_c==1)) {
                    addr_in_dmi_c_idx < addrMgrConst::dmi_memory_coh_domain_start_addr.size();
                } else {
                    addr_in_dmi_c_idx == -1;
                }

                foreach(addrMgrConst::dii_memory_domain_start_addr[i]) {
                    ((sel_mem_region==1) && (addr_in_dii_idx == i)) -> (addr inside {[addrMgrConst::dii_memory_domain_start_addr[i] : addrMgrConst::dii_memory_domain_end_addr[i]]});
                }
                foreach(addrMgrConst::dmi_memory_noncoh_domain_start_addr[i]) {
                    ((sel_mem_region==2) && (addr_in_dmi_nc_idx == i)) -> (addr inside {[addrMgrConst::dmi_memory_noncoh_domain_start_addr[i] : addrMgrConst::dmi_memory_noncoh_domain_end_addr[i]]});
                }
                foreach(addrMgrConst::dmi_memory_coh_domain_start_addr[i]) {
                    ((sel_mem_region==4) && (addr_in_dmi_c_idx == i)) -> (addr inside {[addrMgrConst::dmi_memory_coh_domain_start_addr[i] : addrMgrConst::dmi_memory_coh_domain_end_addr[i]]}) ;
                }
            }
    }
    
    constraint c_addr_constraint_for_axi4_non_excl {
     if (
         port_cfg.axi_interface_type == svt_axi_port_configuration::AXI4 &&
         svt_axi_item_helper::disable_boot_addr_region && 
         use_user_noncoh_addrq==1 && 
         ((xact_type == READ) || (xact_type == WRITE))
         ) {
            addr inside {addrMgrConst::user_addrq[addrMgrConst::NONCOH]};
           }
    }

    constraint c_addr_constraint_for_axi4_non_coh_type {
     if (
         port_cfg.enable_domain_based_addr_gen &&
         !reduce_addr_area                     &&
         !use_user_noncoh_addrq                && 
         port_cfg.axi_interface_type == svt_axi_port_configuration::AXI4 &&
         svt_axi_item_helper::disable_boot_addr_region && 
         ((xact_type == READ) || (xact_type == WRITE))
         ) {
           if(port_cfg.nonshareable_start_addr.size() > 0)
               axi4_nonshareable_addr_range_index < port_cfg.nonshareable_start_addr.size();
           if(port_cfg.innershareable_start_addr.size() > 0)
               axi4_innershareable_addr_range_index < port_cfg.innershareable_start_addr.size();
           if(local_axi4_addr_region_pick_ctl == 0) {
               foreach (port_cfg.nonshareable_start_addr[i]) {
                 (axi4_nonshareable_addr_range_index == i) -> addr inside {[port_cfg.nonshareable_start_addr[i]:
                                                                       port_cfg.nonshareable_end_addr[i]]};
               }
           }
           if(local_axi4_addr_region_pick_ctl == 1) {
               foreach (port_cfg.innershareable_start_addr[i]) {
                 (axi4_innershareable_addr_range_index == i) -> addr inside {[port_cfg.innershareable_start_addr[i]:
                                                                         port_cfg.innershareable_end_addr[i]]};
               }
           }
         }
    }

    constraint c_xact_type_constraint_for_axi4 {
         (port_cfg.axi_interface_type == svt_axi_port_configuration::AXI4 && port_cfg.ace_version == svt_axi_port_configuration::ACE_VERSION_1_0) -> xact_type inside {READ, WRITE};
         (port_cfg.axi_interface_type == svt_axi_port_configuration::AXI4 && port_cfg.ace_version == svt_axi_port_configuration::ACE_VERSION_2_0) -> xact_type inside {READ, WRITE, ATOMIC};
    }
   constraint c_is_unique {
   if(port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE){
     is_unique == 0;
   }
   }
   constraint c_coh_burstlen {
        if (coherent_xact_type inside {READONCE,WRITEUNIQUE} && port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) {
 
        burst_length inside { [1:((port_cfg.cache_line_size*8)/port_cfg.data_width)]};
                                 
    }}
    constraint c_readonce_addr {
        if (coherent_xact_type inside {READONCE,WRITEUNIQUE} && port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) {
 
        //end_addr==addr+((burst_length+1) * 2** burst_size);
        //(addr[`SVT_AXI_ADDR_WIDTH-1 : addrMgrConst::SYS_wSysCacheline] != end_addr[`SVT_AXI_ADDR_WIDTH-1 : addrMgrConst::SYS_wSysCacheline]) -> addr==(addr>>6)<<6;
        (addr[addrMgrConst::SYS_wSysCacheline-1:0] + ((burst_length) * 2** burst_size))<=64;
                                 
    }}
    constraint c_burst_len_cov {
        if (en_127_255_axlen_for_noncoh_txns) {
 
        burst_length dist {[1:127]:=50, [128:255]:=50};
                                 
    }}

<% if(obj.testBench == "fsys") { %>
    `ifdef SVT_AXI_DISABLE_BEAT_LEVEL_PARITY
    constraint c_inject_parity_err_case {
     if(((inject_parity_err_aw_chnl!="")||(inject_parity_err_ar_chnl!="")||(inject_parity_err_w_chnl!="")) && (xact_type != ATOMIC)) {
      burst_size == log_base_2_data_width_in_bytes;
    }}
    `endif
<% } %>


    constraint  c_no_narrow_transfer_for_nonzero_axlen  {
         if (burst_length == 1) {  // FYI, aXlen+1 == burst_length
            (port_cfg.data_width == 8)    -> burst_size <= BURST_SIZE_8BIT;
            (port_cfg.data_width == 16)   -> burst_size <= BURST_SIZE_16BIT;
            (port_cfg.data_width == 32)   -> burst_size <= BURST_SIZE_32BIT;
            (port_cfg.data_width == 64)   -> burst_size <= BURST_SIZE_64BIT;
            (port_cfg.data_width == 128)  -> burst_size <= BURST_SIZE_128BIT;
            (port_cfg.data_width == 256)  -> burst_size <= BURST_SIZE_256BIT;
            (port_cfg.data_width == 512)  -> burst_size <= BURST_SIZE_512BIT;
            (port_cfg.data_width == 1024) -> burst_size <= BURST_SIZE_1024BIT;
        } else {
            (port_cfg.data_width == 8)    -> burst_size == BURST_SIZE_8BIT;
            (port_cfg.data_width == 16)   -> burst_size == BURST_SIZE_16BIT;
            (port_cfg.data_width == 32)   -> burst_size == BURST_SIZE_32BIT;
            (port_cfg.data_width == 64)   -> burst_size == BURST_SIZE_64BIT;
            (port_cfg.data_width == 128)  -> burst_size == BURST_SIZE_128BIT;
            (port_cfg.data_width == 256)  -> burst_size == BURST_SIZE_256BIT;
            (port_cfg.data_width == 512)  -> burst_size == BURST_SIZE_512BIT;
            (port_cfg.data_width == 1024) -> burst_size == BURST_SIZE_1024BIT;
        }
    }
    constraint c_axcache {
      ( xact_type== WRITE) -> cache_type[3] dist {1:=axcache_alloc_wt, 0:=100-axcache_alloc_wt }; 
      ( xact_type== READ)  -> cache_type[2] dist {1:=axcache_alloc_wt, 0:=100-axcache_alloc_wt }; 
    }

    constraint c_axcache_devbuff {
    if (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) {
      if(dev_nonbuf==1) {
        if (xact_type== READ && atomic_type == EXCLUSIVE){
        cache_type == 4'b0000; }}
    }}
    constraint c_same_axid {
      if(axid_collision==1) {
        svt_axi_transaction::id == 0;
      }  
    }
    constraint c_max_id {
      if(max_id==1) {
        if(port_cfg.use_separate_rd_wr_chan_id_width == 1) {
            (xact_type== READ) -> foreach(port_cfg.read_chan_id_width[i]) {
                                    svt_axi_transaction::id[port_cfg.read_chan_id_width[i]] == 1; }
            (xact_type== WRITE) -> foreach(port_cfg.write_chan_id_width[i]) {
                                    svt_axi_transaction::id[port_cfg.write_chan_id_width[i]] == 1; }
        } else {
            foreach(port_cfg.id_width[i]) {
            svt_axi_transaction::id[port_cfg.id_width[i]] == 1;
            }
        }
     }  
    }  
    constraint c_nomultiline {
      if(nomultiline==1) {
        if ((addr[(addrMgrConst::WCACHE_OFFSET):0] + ((burst_length+1) * 2** burst_size)) > (1 << addrMgrConst::WCACHE_OFFSET) ) { 
               addr[(addrMgrConst::WCACHE_OFFSET)-1:0] <<'0;
        }
        burst_length dist { [0 : ((addrMgrConst::WCACHE_OFFSET*8/(port_cfg.data_width)) - 2)] := 25,   ((addrMgrConst::WCACHE_OFFSET*8/(port_cfg.data_width)) - 1) := 75 };

      }
    }
   
    constraint c_data_before_addr {
        if ((xact_type == WRITE) || 
            (xact_type == COHERENT && !(coherent_xact_type inside {EVICT, STASHONCESHARED, STASHONCEUNIQUE}))) {
            if (data_before_addr_for_wr == 0) {
                data_before_addr == 0;
            } else if (data_before_addr_for_wr == 1) {
                data_before_addr == 1;
            }
        }
    }
		constraint c_zero_strb {
			if(zero_wstrb  && ((xact_type ==COHERENT && coherent_xact_type inside{WRITENOSNOOP,WRITEUNIQUE,WRITECLEAN,WRITEBACK}) || xact_type ==WRITE)){
				foreach(wstrb[index]){
						wstrb[index] == '0;
					}
			}
		}
    //CONC-17918
		constraint c_ptl_strb {
		  if(ptl_wstrb  && ((xact_type ==COHERENT && coherent_xact_type inside{WRITENOSNOOP,WRITEUNIQUE,WRITECLEAN,WRITEBACK}) || xact_type ==WRITE)){
			  if(ptl_wstrb == 2'b11){
					foreach(wstrb[index]){
						wstrb[index] inside {[1:((1 << (1 << (burst_size))) - 2)]};
					}
				}else if (ptl_wstrb == 2'b10){
					foreach(wstrb[row,col]){
					  if(col % 2 == 0)
							wstrb[row][col] == 1'b0;
						else 
							wstrb[row][col] == 1'b1;
					}
				}else {
					foreach(wstrb[row,col]){
					  if(col % 2 == 0)
							wstrb[row][col] == 1'b1;
						else 
							wstrb[row][col] == 1'b0;
					}
					
				}
			}
		}

    function bit check_addr_in_dmi_dii_range();
        foreach (addrMgrConst::dii_memory_domain_start_addr[i]) begin
            if(addr inside {[addrMgrConst::dii_memory_domain_start_addr[i]:addrMgrConst::dii_memory_domain_end_addr[i]]}) begin
                return 1;
            end
        end
        foreach (addrMgrConst::dmi_memory_domain_start_addr[i]) begin
            if(addr inside {[addrMgrConst::dmi_memory_domain_start_addr[i]:addrMgrConst::dmi_memory_domain_end_addr[i]]}) begin
                return 1;
            end
        end
         foreach(svt_axi_item_helper::all_dmi_dii_addr_range_start_addr[i]) begin
              if(addr inside {[svt_axi_item_helper::all_dmi_dii_addr_range_start_addr[i]:svt_axi_item_helper::all_dmi_dii_addr_range_end_addr[i]]} && port_cfg.enable_domain_based_addr_gen == 0) begin
                return 1;
              end
         end
        

        return 0;
    endfunction            

    function new(string name = "io_subsys_axi_master_transaction");
        super.new(name);
        if (!$value$plusargs("data_before_addr_for_wr=%d", data_before_addr_for_wr)) begin
           data_before_addr_for_wr='habc; //some garbage
        end 
        if(!$value$plusargs("axcache_alloc_wt=%d", axcache_alloc_wt)) begin
           axcache_alloc_wt=80;
        end 
        if(!$value$plusargs("axid_collision=%d", axid_collision)) begin
          axid_collision=-1;
        end   
	if($test$plusargs("en_excl_txn")) begin
          excl_access_en=1;
        end
        if(!$value$plusargs("exclusive_weight=%d", exclusive_weight)) begin
            std::randomize(exclusive_weight) with {exclusive_weight dist { 5:=60, 95:=20, 1:=10, 99:=10};};
        end
        if(!$value$plusargs("nomultiline=%d", nomultiline)) begin
          nomultiline=-1;
        end   
        if ($test$plusargs("reduce_addr_area")) begin
        reduce_addr_area =1;
        end
        if ($test$plusargs("en_all_axlen_for_noncoh_txns")) begin
           en_all_axlen_for_noncoh_txns =1;
        end
        if ($test$plusargs("en_127_255_axlen_for_noncoh_txns")) begin
           en_127_255_axlen_for_noncoh_txns =1;
        end
        if ($test$plusargs("use_user_noncoh_addrq")) begin
        use_user_noncoh_addrq =1;
        end
        if ($test$plusargs("max_id")) begin
        max_id =1;
        end
        if ($test$plusargs("max_data")) begin
        max_data =1;
        end
        if ($test$plusargs("dev_nonbuf")) begin
        dev_nonbuf =1;
        end
        if ($test$plusargs("nor_mem")) begin
        nor_mem =1;
        end
        if ($test$plusargs("wt_ace_tgt")) begin
        ace_tgt=1;
        end
        if ($test$plusargs("wt_ioc_tgt")) begin
        ioc_tgt=1;
        end
        if ($test$plusargs("wt_chi_tgt")) begin
        chi_tgt=1;
        end
        if ($test$plusargs("ptl_wstrb")) begin
				  std::randomize(ptl_wstrb) with {ptl_wstrb dist {2'b01:=10,2'b10:=10,2'b11:=80};};
        end
        if ($test$plusargs("zero_wstrb")) begin
				  std::randomize(zero_wstrb) with {ptl_wstrb dist {1'b1:=1,1'b0:=99};};
        end
    endfunction: new

    function void pre_randomize(); 
        string port_name, core_str, core_str_tmp;
        //#Stimulus.IOAIU.Normal_txn_parity
        //All parity signals are driven by VIP.
        super.pre_randomize();
        void'($value$plusargs("restrict_addr_to_specific_domain=%0b",restrict_addr_to_specific_domain));
        if(restrict_addr_to_specific_domain) begin : _restrict_addr_to_specific_domain_
            void'($value$plusargs("addr_in_dii=%0b",addr_in_dii));
            void'($value$plusargs("addr_in_dmi_nc=%0b",addr_in_dmi_nc));
            void'($value$plusargs("addr_in_dmi_c=%0b",addr_in_dmi_c));
            sel_mem_region = {addr_in_dmi_c,addr_in_dmi_nc,addr_in_dii};
            assert($countones(sel_mem_region)>0);
            if($countones(sel_mem_region)>1) begin
                do begin
                 bit [1:0]reset_bit;
                   reset_bit = $urandom_range(2,0);
                   sel_mem_region[reset_bit] = 0;                
                end
                while($onehot(sel_mem_region)!=1);
            end
        end : _restrict_addr_to_specific_domain_
<% if(obj.testBench == "fsys") { %>
        if(port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL && io_subsys_axi_dis_inject_intf_parity_err[port_cfg.port_id]==0)begin
<% } else { %>
        if(port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL)begin
<% } %>
           `ifdef SVT_AXI_DISABLE_BEAT_LEVEL_PARITY
                if ($value$plusargs("inject_parity_err_aw_chnl=%0s",inject_parity_err_aw_chnl)||$value$plusargs("inject_parity_err_ar_chnl=%0s",inject_parity_err_ar_chnl)||$value$plusargs("inject_parity_err_w_chnl=%0s", inject_parity_err_w_chnl)) begin
                  svt_axi_transaction :: auto_parity_gen_enable = 0; 
                  port_cfg.loopback_trace_tag_enable = 1;
<% if(obj.testBench == "fsys") { %>
                  if(inject_parity_err_w_chnl!="") begin
                      ZERO_BURST_wt=100;
                      SHORT_BURST_wt=0;
                      LONG_BURST_wt=0;
                  end
<% } %>
                end
           `endif
        end
        
        //`uvm_info(get_full_name(), $psprintf("fn:before pre_randomize ZERO_DELAY_wt:%0d SHORT_DELAY_wt:0x%0d LONG_DELAY_wt:0x%0d\n", ZERO_DELAY_wt, SHORT_DELAY_wt, LONG_DELAY_wt), UVM_LOW);
        
        //`uvm_info(get_full_name(), $psprintf("fn:after pre_randomize port_id:%0d addr:0x%0h burst_length:0x%0h\n", port_id, addr, burst_length), UVM_LOW);
        if (port_cfg != null) begin 
            //`uvm_info(get_full_name(), $psprintf("fn:after pre_randomize *** port_cfg*** \n"), UVM_LOW);
            //port_cfg.print();
        end 
        
        port_name = addrMgrConst::io_subsys_instname_a[port_id];
        core_str_tmp  = port_name.substr(port_name.len()-3, port_name.len()-1);
        if (core_str_tmp inside {"_c0", "_c1", "_c2", "_c3"}) begin 
            core_str = core_str_tmp.substr(core_str_tmp.len()-1, core_str_tmp.len()-1);
            core = core_str.atoi();
            mp_aiu_pri_bitsq = addrMgrConst::mp_aiu_intv_bits[addrMgrConst::io_subsys_funitid_a[port_id]].pri_bits;
            if (mp_aiu_pri_bitsq.size() == 0) begin 
                `uvm_error(get_full_name(), $psprintf("fn:after pre_randomize mp_aiu_pri_bits are not specified for multicore ioaiu"))
            end else begin 
                mp_aiu_pri_bitsq.sort();
                addr_mask = (1 << mp_aiu_pri_bitsq[0]) - 1;
                //`uvm_info(get_full_name(), $psprintf("fn:after super.pre_randomize core:%0d mp_aiu_intrv_bits:%0p addr_mask:0x%0h", core, mp_aiu_pri_bitsq, addr_mask), UVM_LOW)
            end
        end else begin 
            core = -1;
        end
        ZERO_DELAY_wt=100;
        SHORT_DELAY_wt=0;
        LONG_DELAY_wt=0;

        if (clp.get_arg_value("+native_intf_delay=", arg_value)) begin
            native_intf_delay = arg_value;
            if(native_intf_delay=="SHORT")begin
               SHORT_DELAY_wt=100;
               ZERO_DELAY_wt=0;
               LONG_DELAY_wt=0;
            end   
            if(native_intf_delay=="LONG") begin
               LONG_DELAY_wt=100;
               ZERO_DELAY_wt=0;
               SHORT_DELAY_wt=0;
            end   
        end
        if (clp.get_arg_value("+burst_len=", arg_value)) begin
           burst_len = arg_value;
            if(burst_len=="ZERO")begin
               ZERO_BURST_wt=95;
               SHORT_BURST_wt=1;
               LONG_BURST_wt=4;
            end
            if(burst_len=="SHORT")begin
               ZERO_BURST_wt=1;
               SHORT_BURST_wt=95;
               LONG_BURST_wt=4;
            end   
            if(burst_len=="LONG") begin
               ZERO_BURST_wt=1;
               SHORT_BURST_wt=4;
               LONG_BURST_wt=95;
            end
        end
        if(en_all_axlen_for_noncoh_txns == 1) begin //Only enable this plusarg for noncoh transactions testcases(with RdNosnp,WrNosnp txns only)
            reasonable_burst_length.constraint_mode(0);
        end
        if($test$plusargs("dii_target")||$test$plusargs("noncoh_dmi")||$test$plusargs("coh_dmi"))begin
          c_addr_constraint_for_axi4_non_coh_type.constraint_mode(0); 
        end
        //`uvm_info(get_full_name(), $psprintf("fn:after pre_randomize ZERO_DELAY_wt:%0d SHORT_DELAY_wt:0x%0d LONG_DELAY_wt:0x%0d\n ZERO_BURST_wt:0x%0dSHORT_BURST_wt:0x%0d LONG_BURST_wt:0x%0d", ZERO_DELAY_wt, SHORT_DELAY_wt, LONG_DELAY_wt,ZERO_BURST_wt,SHORT_BURST_wt,LONG_BURST_wt), UVM_LOW);

        //`uvm_info(get_full_name(), $psprintf("fn:after post_randomize *** io_subsys_axi_master_transaction *** \n %0s", sprint()), UVM_LOW);
        //CONC-16215 snps case link:https://solvnetplus.synopsys.com/s/case/500WQ00000QuiNb/ace-vip-is-issuing-wrunq-from-an-incorrect-start-state 
        if(port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)begin
          port_cfg.awunique_enable = 0;
        end
    
    endfunction: pre_randomize

    function void post_randomize();
        bit ns;
        super.post_randomize();
<% if(obj.testBench == "fsys") { %>
	if(port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL && io_subsys_axi_dis_inject_intf_parity_err[port_cfg.port_id]==0)begin
           inject_intf_parity_err(); 
	end
<% } else { %>
        if(port_cfg.check_type==svt_axi_port_configuration::ODD_PARITY_BYTE_ALL)begin
           inject_intf_parity_err(); 
	end
<% } %>
        if((dvm_test==0) && !(coherent_xact_type inside {DVMCOMPLETE, DVMMESSAGE}) && svt_axi_item_helper::disable_boot_addr_region) begin
            if(check_addr_in_dmi_dii_range==0) begin
                $display("***************svt_axi_master_transaction*************** \n %0s",sprint());
                foreach(svt_axi_item_helper::all_dmi_dii_addr_range_start_addr[i]) begin
                    $display("[%0d'h%16h:%0d'h%16h]",`SVT_AXI_ADDR_WIDTH,svt_axi_item_helper::all_dmi_dii_addr_range_start_addr[i],`SVT_AXI_ADDR_WIDTH,svt_axi_item_helper::all_dmi_dii_addr_range_end_addr[i]);
                end
                `uvm_fatal(get_full_name(),$psprintf("Randomization failure!! \n Target addr 'h%0h is not in above range.",addr))
            end
        end
      
        //if (xact_type == WRITE) begin 
            //`uvm_info(get_full_name(), $psprintf("fn:after post_randomize data_before_addr:%0d addr_valid_delay:%0d\n", data_before_addr, addr_valid_delay), UVM_LOW);
        //end
       
        if (port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) begin  
            if (prot_type inside {DATA_SECURE_NORMAL, DATA_SECURE_PRIVILEGED, INSTRUCTION_SECURE_NORMAL, INSTRUCTION_SECURE_PRIVILEGED}) ns = 0;
            else ns = 1;
            //`uvm_info(get_full_name(), $psprintf("fn:after post_randomize *** io_subsys_axi_master_transaction *** coherent_xact_type:%0p addr:0x%0h ns:%0b initial_cacheline_st:%0p final_cacheline_state:%0p prefinal_cacheline_state:%0p", coherent_xact_type, addr, ns, initial_cache_line_state, final_cache_line_state, prefinal_cache_line_state), UVM_LOW);
        end
        if(stash_nid_valid && port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE && port_cfg.ace_version == svt_axi_port_configuration::ACE_VERSION_2_0)begin
           if($test$plusargs("wt_ace_tgt") || $test$plusargs("wt_ioc_tgt") || $test$plusargs("wt_chi_tgt")) begin
              randcase
               ace_tgt: if($size(addrMgrConst::stash_nids_target_ace_aius)>0)std::randomize(stash_nid)with{stash_nid inside{addrMgrConst::stash_nids_target_ace_aius};};
               ioc_tgt: if($size(addrMgrConst::stash_nids_target_axi_aius)>0)std::randomize(stash_nid)with{stash_nid inside{addrMgrConst::stash_nids_target_axi_aius};};
               chi_tgt: if($size(addrMgrConst::stash_nids_target_chi_aius)>0)std::randomize(stash_nid)with{stash_nid inside{addrMgrConst::stash_nids_target_chi_aius};};
              endcase
           end
           else begin
              randcase
               80: if($size(addrMgrConst::stash_nids)>0)std::randomize(stash_nid)with{stash_nid inside{addrMgrConst::stash_nids};};
               15: if($size(addrMgrConst::stash_nids_non_chi_aius)>0)std::randomize(stash_nid)with{stash_nid inside{addrMgrConst::stash_nids_non_chi_aius};};
               5: stash_nid = stash_nid;
              endcase
           end
        end

        if ($test$plusargs("random_gpra_nsx")) begin
                  //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                    prot_type[1] = addrMgrConst::get_addr_gprar_nsx(addr) ;
        end
        
    endfunction: post_randomize


   function void inject_intf_parity_err();
        //#Stimulus.IOAIU.Normal_txn_parity_Err
				bit error_inject =0;
				bit single_bit_parity_error;
				int single_bit_parity_errror_pct;
				if(!$value$plusargs("single_bit_parity_errror_pct=%0d",single_bit_parity_errror_pct))begin
				  single_bit_parity_errror_pct = $urandom_range(80,100);
				end
				std::randomize(single_bit_parity_error)with{single_bit_parity_error dist {1:=single_bit_parity_errror_pct,0:=(100-single_bit_parity_errror_pct)};};
       `ifdef SVT_AXI_DISABLE_BEAT_LEVEL_PARITY
            

            if($value$plusargs("inject_parity_err_aw_chnl=%0s",inject_parity_err_aw_chnl))begin                  
<% if(obj.testBench == "fsys") { %>
                 if(inject_parity_err_aw_chnl== "AXI5")begin
                     randcase
                     //1 : inject_parity_err_aw_chnl = "AWVALID_CHK";
                     //1 : inject_parity_err_aw_chnl = "AWREADY_CHK";
                     1 : inject_parity_err_aw_chnl = "AWID_CHK";
                     1 : inject_parity_err_aw_chnl = "AWADDR_CHK";
                     1 : inject_parity_err_aw_chnl = "AWLEN_CHK";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK0";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK1";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK3";
                     endcase
                 end
                 if(inject_parity_err_aw_chnl== "ACE5LITE")begin
                     randcase
                     //1 : inject_parity_err_aw_chnl = "AWVALID_CHK";
                     //1 : inject_parity_err_aw_chnl = "AWREADY_CHK";
                     1 : inject_parity_err_aw_chnl = "AWID_CHK";
                     5 : inject_parity_err_aw_chnl = "AWADDR_CHK";
                     1 : inject_parity_err_aw_chnl = "AWLEN_CHK";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK0";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK1";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK2";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK3";
                     //1 : inject_parity_err_aw_chnl = "AWSTASHNID_CHK";
                     //1 : inject_parity_err_aw_chnl = "AWSTASHLPID_CHK";
                     1 : inject_parity_err_aw_chnl = "AWTRACE_CHK";
                     endcase
                 end
                 if(inject_parity_err_aw_chnl== "AWSTASH")begin
                     randcase
                     1 : inject_parity_err_aw_chnl = "AWSTASHNID_CHK";
                     1 : inject_parity_err_aw_chnl = "AWSTASHLPID_CHK";
                     endcase
                 end
                 if(inject_parity_err_aw_chnl== "ACE5")begin
                     randcase
                     //1 : inject_parity_err_aw_chnl = "AWVALID_CHK";
                     //1 : inject_parity_err_aw_chnl = "AWREADY_CHK";
                     1 : inject_parity_err_aw_chnl = "AWID_CHK";
                     3 : inject_parity_err_aw_chnl = "AWADDR_CHK";
                     1 : inject_parity_err_aw_chnl = "AWLEN_CHK";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK0";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK1";
                     1 : inject_parity_err_aw_chnl = "AWCTL_CHK2";
                     endcase
                 end


<% } %>
                 if(inject_parity_err_aw_chnl== "AWID_CHK")begin                           
                     svt_axi_transaction::user_inject_parity_signal_array[AWIDCHK_EN] = 1;
                     for(int i=0; i<$bits(awid_chk);i++)begin
		     do 
                         awid_chk[i] = $random();
                     while (($countones(awid_chk[i]) + $countones(id[i*8 +: 8])) %2 ==1);
                     end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 if(inject_parity_err_aw_chnl== "AWADDR_CHK")begin                           
                     svt_axi_transaction::user_inject_parity_signal_array[AWADDRCHK_EN] = 1;
                     for(int i=0; i<$bits(awaddr_chk);i++)begin
		     do
                         awaddr_chk[i] = $urandom;
		     while (($countones(awaddr_chk[i] ) + $countones(addr[i*8 +: 8])) %2 ==1);
                     end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 if(inject_parity_err_aw_chnl== "AWLEN_CHK")begin                           
                     svt_axi_transaction::user_inject_parity_signal_array[AWLENCHK_EN] = 1;
		     do
                     awlen_chk = $urandom;
		     while (($countones(awlen_chk ) + $countones(burst_length-1)) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 if(inject_parity_err_aw_chnl== "AWCTL_CHK0")begin                           
                     svt_axi_transaction::user_inject_parity_signal_array[AWCTLCHK0_EN] = 1;
                     do
                     awctl_chk0 = $urandom;
		     while (($countones(awctl_chk0) + $countones(burst_size)+$countones(burst_type)+$countones(atomic_type)+$countones(prot_type)) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 if(inject_parity_err_aw_chnl== "AWCTL_CHK1")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[AWCTLCHK1_EN] = 1;
                     do
                     awctl_chk1 = $urandom;
                     while (($countones(awctl_chk1) + $countones(region)+$countones(cache_type)+$countones(qos)) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 if(inject_parity_err_aw_chnl== "AWCTL_CHK3")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[AWCTLCHK3_EN] = 1;
                     awctl_chk3 = $urandom;
                     awatop = decode_atomic_xact_op_type(atomic_xact_op_type);
                     do
                     awctl_chk3 = ~ awctl_chk3;
                     while (($countones(awctl_chk3) + $countones(awatop)) %2 ==1); //atomic_xact_op_type = AWATOP 
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 
                 if(inject_parity_err_aw_chnl== "AWUSER_CHK")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[AWUSERCHK_EN] = 1;
                     for(int i=0; i<$bits(awuser_chk);i++)begin
                     do
                     awuser_chk[i] = $urandom;
                     while (($countones(awuser_chk[i]) + $countones(addr_user[i*8 +:8])) %2 ==1);
                     end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                                 
                 if(inject_parity_err_aw_chnl== "AWTRACE_CHK")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[AWTRACECHK_EN] = 1;
                     do
                     awtrace_chk = $urandom;
                     while (($countones(awtrace_chk) + $countones(trace_tag)) %2 ==1);                      
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                
                 if(inject_parity_err_aw_chnl== "AWCTL_CHK2")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[AWCTLCHK2_EN] = 1;
                     axsnoop = decode_coherent_xact_type(coherent_xact_type);
                     do
                     awctl_chk2 = $urandom;
                     while (($countones(awctl_chk2) + $countones(domain_type) + $countones(axsnoop) + $countones(barrier_type)+ ((port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)?$countones(is_unique):0)) %2 ==1); 
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 if(inject_parity_err_aw_chnl== "AWSTASHNID_CHK")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[AWSTASHNIDCHK_EN] = 1;
                     do
                     awstashnid_chk = $urandom;
                     while (($countones(awstashnid_chk) + $countones(stash_nid) + $countones(stash_nid_valid)) %2 ==1);                      
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 if(inject_parity_err_aw_chnl== "AWSTASHLPID_CHK")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[AWSTASHLPIDCHK_EN] = 1;
                     do
                     awstashlpid_chk = $urandom;
                     while (($countones(awstashlpid_chk) + $countones(stash_lpid) + $countones(stash_lpid_valid)) %2 ==1);                      
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
                 `uvm_info(get_full_name(), $psprintf("inject_intf_parity_err.inject_parity_err_aw_chnl %0s",inject_parity_err_aw_chnl), UVM_NONE);
                 if(!(inject_parity_err_aw_chnl== "AWTRACE_CHK"))begin
                   trace_tag = 0; 
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
             end

      if ($value$plusargs("inject_parity_err_ar_chnl=%0s",inject_parity_err_ar_chnl)) begin
<% if(obj.testBench == "fsys") { %>
             if(inject_parity_err_ar_chnl== "AXI5")begin
                 randcase
                 //1 : inject_parity_err_ar_chnl = "ARVALID_CHK";
                 //1 : inject_parity_err_ar_chnl = "ARREADY_CHK";
                 1 : inject_parity_err_ar_chnl = "ARID_CHK";
                 1 : inject_parity_err_ar_chnl = "ARADDR_CHK";
                 1 : inject_parity_err_ar_chnl = "ARLEN_CHK";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK0";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK1";
                 endcase
            end
            if(inject_parity_err_ar_chnl== "ACE5LITE")begin
                 randcase
                 //1 : inject_parity_err_ar_chnl = "ARVALID_CHK";
                 //1 : inject_parity_err_ar_chnl = "ARREADY_CHK";
                 1 : inject_parity_err_ar_chnl = "ARID_CHK";
                 4 : inject_parity_err_ar_chnl = "ARADDR_CHK";
                 1 : inject_parity_err_ar_chnl = "ARLEN_CHK";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK0";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK1";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK2";
                 1 : begin
                       if(port_cfg.sys_cfg.dvm_version == svt_axi_system_configuration::DVMV8_1)begin
                          inject_parity_err_ar_chnl = "ARCTL_CHK3";
                       end else begin
                          inject_parity_err_ar_chnl = "ARADDR_CHK";
                       end
                     end
                 1 : inject_parity_err_ar_chnl = "ARTRACE_CHK";
                 endcase
            end
            if(inject_parity_err_ar_chnl== "ACE5")begin
                 randcase
                 //1 : inject_parity_err_ar_chnl = "ARVALID_CHK";
                 //1 : inject_parity_err_ar_chnl = "ARREADY_CHK";
                 1 : inject_parity_err_ar_chnl = "ARID_CHK";
                 3 : inject_parity_err_ar_chnl = "ARADDR_CHK";
                 1 : inject_parity_err_ar_chnl = "ARLEN_CHK";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK0";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK1";
                 1 : inject_parity_err_ar_chnl = "ARCTL_CHK2";
                 endcase
            end


<% } %>
            if(inject_parity_err_ar_chnl== "ARID_CHK")begin
                svt_axi_transaction::user_inject_parity_signal_array[ARIDCHK_EN] = 1;
                for(int i=0; i<$bits(arid_chk);i++)begin
		do
                arid_chk[i] = $urandom;
		while (($countones(arid_chk[i] ) + $countones(id[i*8 +: 8])) %2 ==1);
                end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            if(inject_parity_err_ar_chnl== "ARADDR_CHK")begin  
                svt_axi_transaction::user_inject_parity_signal_array[ARADDRCHK_EN] = 1;
                for(int i=0; i<$bits(araddr_chk);i++)begin
		do
                araddr_chk[i] = $urandom;
                while (($countones(araddr_chk[i] ) + $countones(addr[i*8 +:8])) %2 ==1);
                end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            if(inject_parity_err_ar_chnl== "ARLEN_CHK")begin     
                svt_axi_transaction::user_inject_parity_signal_array[ARLENCHK_EN] = 1;
		do
                arlen_chk = $urandom;
		while (($countones(arlen_chk ) + $countones(burst_length-1)) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            if(inject_parity_err_ar_chnl== "ARCTL_CHK0")begin     
                svt_axi_transaction::user_inject_parity_signal_array[ARCTLCHK0_EN] = 1;
                do
                arctl_chk0 = $urandom;
		while (($countones(arctl_chk0) + $countones(burst_size)+$countones(burst_type)+$countones(atomic_type)+$countones(prot_type)) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            if(inject_parity_err_ar_chnl== "ARCTL_CHK1")begin     
                svt_axi_transaction::user_inject_parity_signal_array[ARCTLCHK1_EN] = 1;
                do
                arctl_chk1 = $urandom;
                while (($countones(arctl_chk1) + $countones(region)+$countones(cache_type)+$countones(qos)) %2 ==1);                
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            if(inject_parity_err_ar_chnl== "ARCTL_CHK2")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[ARCTLCHK2_EN] = 1;
                     axsnoop = decode_coherent_xact_type(coherent_xact_type);
                     do
                     arctl_chk2 = $urandom;
                     while (($countones(arctl_chk2) + $countones(domain_type) + $countones(axsnoop) + $countones(barrier_type)) %2 ==1);                         `uvm_info("i am here",$sformatf("arctl_chk2=%0b,domain_type=%0b,coherent_xact_type=%0s,coherent_xact_type=%0b,barrier_type=%0b,addr:0x%0h,id:0x%0h",arctl_chk2,domain_type,coherent_xact_type,coherent_xact_type,barrier_type,addr,id),UVM_LOW) 
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
             end
            
            if(inject_parity_err_ar_chnl== "ARCTL_CHK3")begin     
                svt_axi_transaction::user_inject_parity_signal_array[ARCTLCHK3_EN] = 1;
                do
                arctl_chk3 = $urandom;
                while (($countones(arctl_chk3) + $countones(arvmid)) %2 ==1); //arvmidext                
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
           
            
            if(inject_parity_err_ar_chnl== "ARUSER_CHK")begin     
                svt_axi_transaction::user_inject_parity_signal_array[ARUSERCHK_EN] = 1;
                for(int i=0; i<$bits(aruser_chk);i++)begin
		do
                aruser_chk[i] = $urandom;
		while (($countones(aruser_chk[i] ) + $countones(addr_user[i*8 +:8])) %2 ==1);
                end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            
            
            if(inject_parity_err_ar_chnl== "ARTRACE_CHK")begin     
                svt_axi_transaction::user_inject_parity_signal_array[ARTRACECHK_EN] = 1;
		do
                artrace_chk = $urandom;
		while (($countones(artrace_chk ) + $countones(trace_tag)) %2 ==1);
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            `uvm_info(get_full_name(), $psprintf("inject_intf_parity_err.inject_parity_err_ar_chnl %0s",inject_parity_err_ar_chnl), UVM_NONE);
            if(!(inject_parity_err_ar_chnl== "ARTRACE_CHK"))begin
              trace_tag = 0;
            end
      end
      if ($value$plusargs("inject_parity_err_w_chnl=%0s", inject_parity_err_w_chnl)) begin
<% if(obj.testBench == "fsys") { %>
            if(inject_parity_err_w_chnl== "ACE5" || inject_parity_err_w_chnl== "AXI5")begin
                 randcase
                 //1 : inject_parity_err_w_chnl = "WVALID_CHK";
                 //1 : inject_parity_err_w_chnl = "WREADY_CHK";
                 1 : inject_parity_err_w_chnl = "WDATA_CHK";
                 1 : inject_parity_err_w_chnl = "WSTRB_CHK";
                 1 : inject_parity_err_w_chnl = "WLAST_CHK";
                 endcase
            end
            if(inject_parity_err_w_chnl== "ACE5LITE")begin
                 randcase
                 //1 : inject_parity_err_w_chnl = "WVALID_CHK";
                 //1 : inject_parity_err_w_chnl = "WREADY_CHK";
                 1 : inject_parity_err_w_chnl = "WDATA_CHK";
                 1 : inject_parity_err_w_chnl = "WSTRB_CHK";
                 1 : inject_parity_err_w_chnl = "WLAST_CHK";
                 1 : inject_parity_err_w_chnl = "WTRACE_CHK";
                 endcase
            end
<% } %>
            if(inject_parity_err_w_chnl== "WDATA_CHK")begin  
                svt_axi_transaction::user_inject_parity_signal_array[WDATACHK_EN] = 1;
                for(int i=0; i<$bits(wdata_chk);i++)begin
		do
                wdata_chk[i] = $urandom;
		while (($countones(wdata_chk[i] ) + $countones(data[i*8 +:8])) %2 ==1);
                end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            if(inject_parity_err_w_chnl== "WSTRB_CHK")begin                     
                svt_axi_transaction::user_inject_parity_signal_array[WSTRBCHK_EN] = 1;
								// Iterate through each byte lane of the wstrb signal
								foreach(wstrb[i]) begin
								    // Skip if we don't need to inject an error on this byte lane
								    if (($urandom_range(0, 1) == 0 && (wstrb.size() - 1 != i || error_inject))) begin
								        continue;
								    end
								
								    // The logic inside this loop is complex; let's break it down.
								    // It seems to be trying to inject a bit flip (parity error) into one byte of wstrb.
								    // The inner loop iterates through the bytes of a larger wstrb element if wstrb is not a simple byte array.
								    for (int j = 0; j < ($bits(wstrb[i]) / 8); j++) begin
								        // Decide whether to inject an error into this specific byte
								        if ($urandom_range(0, 1) == 0 && (j != (($bits(wstrb[i]) / 8) - 1) || error_inject)) begin
								            continue;
								        end	

								        // Loop until we find a value for wstrb_chk that flips the parity
								        // of the original byte (wstrb_byte).
								        do begin
								            wstrb_chk[j] = $urandom;
								        end while (($countones(wstrb_chk[j]) + $countones(wstrb[i][j*8 +: 8])) % 2 == 1);								        
												`uvm_info("i am here",$sformatf("wstrb_chk[%0d]=%0b,wstrb[%0d][j=%0d]=%0h",j,wstrb_chk[j],i,j,wstrb[i][j*8 +: 8]),UVM_LOW)
												// Flag that an error has been injected
								        error_inject = 1;
								    end
										   if(single_bit_parity_error==1'b1 && error_inject == 1'b1)begin
											   break;
											 end
								end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            if(inject_parity_err_w_chnl== "WLAST_CHK")begin
                      
                svt_axi_transaction::user_inject_parity_signal_array[WLASTCHK_EN] = 1;
                wlast_chk = 1;
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
            end
            
                 if(inject_parity_err_w_chnl== "WUSER_CHK")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[WUSERCHK_EN] = 1;
                     for(int i=0; i<$bits(wuser_chk);i++)begin
                     do
                     wuser_chk[i] = $urandom;
                     while (($countones(wuser_chk[i]) + $countones(data_user[i*8 +: 8])) %2 ==1); 
                     end
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
                 end
          
          
               if(inject_parity_err_w_chnl== "WTRACE_CHK")begin 
                     svt_axi_transaction::user_inject_parity_signal_array[WTRACECHK_EN] = 1; 
                     do
                     wtrace_chk = $urandom;
                     while (($countones(wtrace_chk) + $countones(trace_tag)) %2 ==1); 
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
               end
              `uvm_info(get_full_name(), $psprintf("inject_intf_parity_err.inject_parity_err_w_chnl %0s",inject_parity_err_w_chnl), UVM_NONE);
               if(!(inject_parity_err_w_chnl== "WTRACE_CHK"))begin
                 data_trace_tag = 0;
<% if(obj.testBench == "fsys") { %> io_subsys_axi_intf_parity_err_count[port_cfg.port_id] = io_subsys_axi_intf_parity_err_count[port_cfg.port_id] + 1; <% } %>
               end
     end
          `endif
   endfunction
   function bit[5:0] decode_atomic_xact_op_type (bit[4:0] decode_atomic_xact_type);

     case(decode_atomic_xact_type)
       0: decode_atomic_xact_op_type =6'b010000 ; 
       1: decode_atomic_xact_op_type =6'b010001 ;  
       2: decode_atomic_xact_op_type =6'b010010 ; 
       3: decode_atomic_xact_op_type =6'b010011 ;
       4: decode_atomic_xact_op_type =6'b010100 ;
       5: decode_atomic_xact_op_type =6'b010101 ;
       6: decode_atomic_xact_op_type =6'b010110 ;
       7: decode_atomic_xact_op_type =6'b010111 ;
       8: decode_atomic_xact_op_type =6'b100000 ;
       9: decode_atomic_xact_op_type =6'b100001 ;
       10:decode_atomic_xact_op_type =6'b100010 ;
       11:decode_atomic_xact_op_type =6'b100011 ;
       12:decode_atomic_xact_op_type =6'b100100 ;
       13:decode_atomic_xact_op_type =6'b100101 ;
       14:decode_atomic_xact_op_type =6'b100110 ;
       15:decode_atomic_xact_op_type =6'b100111 ;
       16:decode_atomic_xact_op_type =6'b110000 ;
       17:decode_atomic_xact_op_type =6'b110001 ;
       default : `uvm_warning(get_full_name,$sformatf("atomic type is not correct"))
     endcase
   endfunction

   function bit [3:0] decode_coherent_xact_type (int coherent_xact_type);

     case(coherent_xact_type)
       READNOSNOOP          : decode_coherent_xact_type = 4'b0000;
       READONCE             : decode_coherent_xact_type = 4'b0000;
       READSHARED           : decode_coherent_xact_type = 4'b0001;
       READCLEAN            : decode_coherent_xact_type = 4'b0010;
       READNOTSHAREDDIRTY   : decode_coherent_xact_type = 4'b0011;
       READUNIQUE           : decode_coherent_xact_type = 4'b0111;
       CLEANUNIQUE          : decode_coherent_xact_type = 4'b1011;
       MAKEUNIQUE           : decode_coherent_xact_type = 4'b1100;
       CLEANSHARED          : decode_coherent_xact_type = 4'b1000;
       CLEANINVALID         : decode_coherent_xact_type = 4'b1001;
       MAKEINVALID          : decode_coherent_xact_type = 4'b1101;
       DVMCOMPLETE          : decode_coherent_xact_type = 4'b1110;
       DVMMESSAGE           : decode_coherent_xact_type = 4'b1111;
       WRITENOSNOOP         : decode_coherent_xact_type = 4'b0000;
       WRITEUNIQUE          : decode_coherent_xact_type = 4'b0000;
       WRITELINEUNIQUE      : decode_coherent_xact_type = 4'b0001;
       WRITECLEAN           : decode_coherent_xact_type = 4'b0010;
       WRITEBACK            : decode_coherent_xact_type = 4'b0011;
       EVICT                : decode_coherent_xact_type = 4'b0100;
       WRITEEVICT           : decode_coherent_xact_type = 4'b0101;
       CLEANSHAREDPERSIST   : decode_coherent_xact_type = 4'b1010;
      `ifdef SVT_ACE5_ENABLE
       WRITEPTLCMO          : decode_coherent_xact_type = 4'b1010;    
       WRITEFULLCMO         : decode_coherent_xact_type = 4'b1011;
       STASHTRANSLATION     : decode_coherent_xact_type = 4'b1110;      
       STASHONCESHARED      : decode_coherent_xact_type = 4'b1100;      
       STASHONCEUNIQUE      : decode_coherent_xact_type = 4'b1101;      
       WRITEUNIQUEPTLSTASH  : decode_coherent_xact_type = 4'b1000;   
       WRITEUNIQUEFULLSTASH : decode_coherent_xact_type = 4'b1001;   
       CMO                  : decode_coherent_xact_type = 4'b0110;   
       `endif
       READONCECLEANINVALID : decode_coherent_xact_type = 4'b0100;
       READONCEMAKEINVALID  : decode_coherent_xact_type = 4'b0101;
       default : `uvm_warning(get_full_name,$sformatf("Coherent xact type is not correct"))
     endcase
   endfunction
endclass: io_subsys_axi_master_transaction
`endif // `ifndef GUARD_IO_SUBSYS_AXI_MASTER_TRANSACTION_SVH
