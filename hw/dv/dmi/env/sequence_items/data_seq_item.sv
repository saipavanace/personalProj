class data_seq_item extends dmi_seq_item;
    
    int beatn;
    int num_dtw_cycles_smi, num_dtw_cycles;
    int initiator_intf_size_in_bytes;
    smi_addr_t swap_addr;
    bit noncoh_non_CA_EX;
    int align_size;

    rand int num_payload_bytes;
    rand bit abort_full_data_gen, abort_data_gen; 
    rand bit abort_addr_gen;

    rand bit all_BE_on;
    rand bit avoid_SCP_addr;
    `uvm_object_utils_begin(data_seq_item)
    `uvm_object_utils_end

    constraint default_c{
      soft abort_full_data_gen == 0;
      soft abort_data_gen == 0;
      soft abort_addr_gen == 0;
      soft all_BE_on      == 0;
      soft avoid_SCP_addr == 0;
      soft num_payload_bytes == 0;
      smi_ac dist {
        0 := 5,
        1 := 5
      };
      smi_ns dist{
        0 := 5,
        1 := 5 
      };
      <%if (obj.wSecurityAttribute==0){%>
      smi_ns == 0;
      <%} else { %>
      smi_ns dist {
        0 := 5,
        1 := 5
      };
      <%}%>
      if(!args.k_shared_c_nc_addressing) {
        m_addr_type == NONCOH -> smi_ac == 0; //Enforce NC transaction SysArch Table5-9
      }
    }
    extern function set_payload_size();
    extern function set_intfsize();
    extern function align_compare_atomic(output int min_be, int max_be);
    extern function int get_align_size();
    extern function align_address();
    extern function assign_address();

    extern function set_data_guidance();
    extern function set_data_fields();
    extern function print_payload_data();
    extern function construct_write_data();
    extern function construct_data();
    extern function construct_data_for_preset_payload();
    extern function copy_data_for_atm_cmp(smi_seq_item _rhs);
    
    function new(string name = "data_seq_item");
      super.new(name);
    endfunction
    //Construct
endclass

function data_seq_item::construct_data();
  if(!abort_full_data_gen) begin
    set_payload_size();
    set_intfsize();
    set_data_guidance();
    align_size = get_align_size();
    construct_data_for_preset_payload();
  end
endfunction

function data_seq_item::construct_data_for_preset_payload();
  if(!abort_full_data_gen) begin
    align_address();
    if(cfg.isAtomics(smi_msg_type) || cfg.isNcWr(smi_msg_type) || cfg.isAnyDtw(smi_msg_type)) begin
      if(!abort_data_gen) begin
        construct_write_data();
      end
    end
  end
endfunction

function data_seq_item::copy_data_for_atm_cmp(smi_seq_item _rhs);
  //As the title indicates, this is a very specific copy function.
  int start_index, start_byte_addr, end_byte_addr;
  int rhs_start_index, rhs_start_byte_addr, rhs_end_byte_addr;
  num_payload_bytes = (2**_rhs.smi_size) * 2;
  smi_dp_be       = _rhs.smi_dp_be;
  smi_size        = $clog2(num_payload_bytes);
  smi_mpf1_asize  = $clog2(num_payload_bytes);
  smi_mpf1_alength= 0;
  set_intfsize();
  align_size = get_align_size();
  align_address();
  set_data_guidance();
  set_data_fields();
  //Copy previously written data to achieve a compare match
  num_payload_bytes = (2**_rhs.smi_size) * 2;
  start_index = (swap_addr > smi_addr) ? 0 : (smi_addr[($clog2(SYS_nSysCacheline)-1):3]-swap_addr[($clog2(SYS_nSysCacheline)-1):3]);
  start_byte_addr = {start_index, smi_addr[2:0]}; 
  end_byte_addr = start_byte_addr + (num_payload_bytes/2);
  rhs_start_byte_addr = {1'b0,_rhs.smi_addr[2:0]};

  for(int i = start_byte_addr, j=rhs_start_byte_addr; i <end_byte_addr;i++,j++) begin
    int dw_index = i[$clog2(SYS_nSysCacheline)-1:3];
    int dw_byte_addr = i[2:0];
    int r_idx = j[$clog2(SYS_nSysCacheline)-1:3];
    int r_byte = j[2:0];
    `uvm_info(get_type_name(),$sformatf("::atomic_cmp_match::  Copying previously written data for a compare match"),UVM_DEBUG)
    `uvm_info(get_type_name(),$sformatf("::atomic_cmp_match::  LHS(%0d)  |   RHS(%0d) ",i,j),UVM_DEBUG)
    `uvm_info(get_type_name(),$sformatf("::atomic_cmp_match::  dw:%0d    |   dw:%0d   ",dw_index, r_idx),UVM_DEBUG)
    `uvm_info(get_type_name(),$sformatf("::atomic_cmp_match::  byte:%0d  |   byte:%0d ",dw_byte_addr, r_byte),UVM_DEBUG)
    `uvm_info(get_type_name(),$sformatf("::atomic_cmp_match::  data:%0h  |   data:%0h ",smi_dp_data[dw_index][dw_byte_addr*8+:8],_rhs.smi_dp_data[r_idx][r_byte*8+:8]),UVM_DEBUG)
    this.smi_dp_data[dw_index][dw_byte_addr*8+:8] = _rhs.smi_dp_data[r_idx][r_byte*8+:8];
  end
  print_payload_data();
endfunction

function data_seq_item::construct_write_data();
  //Sets Data and BE fields 
  set_data_fields();
  print_payload_data();
endfunction

function data_seq_item::print_payload_data();
  `uvm_info(get_type_name(),
            $sformatf("::payload:: addr:0x%0h num_payload_bytes:0x%0d num_dtw_cycles:%0d num_dtw_cycles_smi:%0d beatn :%0b smi_size:0x%x Cacheline:0x%x WDATA:0x%x", smi_addr, num_payload_bytes,
                      num_dtw_cycles,num_dtw_cycles_smi,beatn,smi_size,N_SYS_CACHELINE, W_DATA),UVM_HIGH)
  foreach(smi_dp_data[i])begin
    `uvm_info(get_type_name(),$sformatf("::payload:: smi_dp_data[%0d] :%0x",i,smi_dp_data[i]),UVM_DEBUG);
    `uvm_info(get_type_name(),$sformatf("::payload:: smi_dp_be[%0d]   :%0b",i,smi_dp_be[i]),UVM_DEBUG);
    `uvm_info(get_type_name(),$sformatf("::payload:: smi_dp_dwid[%0d] :%0x",i,smi_dp_dwid[i]),UVM_DEBUG);
    `uvm_info(get_type_name(),$sformatf("::payload:: smi_dp_dbad[%0d] :%0b",i,smi_dp_dbad[i]),UVM_DEBUG);
  end
endfunction
  
function data_seq_item::align_compare_atomic(output int min_be, int max_be);
  smi_addr_t min_addr, min_addr_beat_aligned, initiator_beat_aligned_addr;
  int swap_min_be_pos, cmp_min_be_pos;
  int atm_cmp_dtw_cycles;
  int initiator_intfsize_in_dwords = (2**smi_intfsize);
  int initiator_intfsize_in_bytes = (2**smi_intfsize)*8;
  int payload_size_in_bytes = (2**smi_size);
  int num_cmp_bytes = payload_size_in_bytes/2;

  //Atomic compares holds two data components of equal size [Compare Value | Swap Value]
  swap_addr = smi_addr;
  swap_addr[$clog2(num_cmp_bytes)] = ~smi_addr[$clog2(num_cmp_bytes)];
  initiator_beat_aligned_addr = cfg.align(smi_addr,initiator_intfsize_in_bytes);
  swap_min_be_pos = swap_addr - initiator_beat_aligned_addr;
  cmp_min_be_pos  = smi_addr - initiator_beat_aligned_addr;
  //Outbound data must be aligned to data size. Address of compare value is aligned to size and then the swap value is poisioned
  if(payload_size_in_bytes <= initiator_intfsize_in_bytes) begin
    min_be = (swap_min_be_pos < cmp_min_be_pos) ? swap_min_be_pos : cmp_min_be_pos;
    max_be = min_be + payload_size_in_bytes;
  end
  else begin
    atm_cmp_dtw_cycles = payload_size_in_bytes/initiator_intfsize_in_bytes;
    min_addr = (swap_addr < smi_addr) ? swap_addr : smi_addr;
    min_addr_beat_aligned = cfg.align(min_addr,initiator_intfsize_in_bytes);
    min_be = min_addr - min_addr_beat_aligned;
    max_be = min_be + atm_cmp_dtw_cycles*(initiator_intfsize_in_bytes);
  end

  `uvm_info(get_type_name(),$sformatf("::align_cmp_atm:: num_cmp_bytes:%0d Swap_addr:%0h swap_addr[$clog2(num_cmp_bytes)]:%0h =~ smi_addr[$clog2(num_cmp_bytes)]:%0h",
                                                          num_cmp_bytes, swap_addr, swap_addr[$clog2(num_cmp_bytes)], smi_addr[$clog2(num_cmp_bytes)]),UVM_DEBUG)
  `uvm_info(get_type_name(),$sformatf("::align_cmp_atm:: swap_min_be_pos:%0d cmp_min_be_pos:%0d",swap_min_be_pos,cmp_min_be_pos),UVM_DEBUG)
  `uvm_info(get_type_name(),$sformatf("::align_cmp_atm:: payload sized %0s than interface", (payload_size_in_bytes <= initiator_intfsize_in_bytes) ? "smaller" : "larger"),UVM_DEBUG)
  `uvm_info(get_type_name(),$sformatf("::align_cmp_atm:: min_be_bit:%0d max_be_bit:%0d", min_be, max_be),UVM_DEBUG)
  `uvm_info(get_type_name(),$sformatf("::align_cmp_atm:: atm_cmp_dtw_cycles=%0d min_addr:%0h min_addr_b_aligned:%0h", atm_cmp_dtw_cycles, min_addr, min_addr_beat_aligned),UVM_DEBUG)

endfunction

function data_seq_item::set_data_fields();
  int min_be_bit, max_be_bit, be_counter;
  int dwid, dwid_h, dwid_l;
  smi_addr_t initiator_beat_aligned_addr, local_smi_addr;
  int initiator_intfsize_in_dwords = (2**smi_intfsize);
  int initiator_intfsize_in_bytes = (2**smi_intfsize)*8;
  int payload_size_in_bytes = (2**smi_size);
  int smi_dp_size;
  bit deassert_be;
  bit prev_BE_val;
  int dwid_itr=0;
  bit [7:0]               local_dp_be   [8];
  bit                     local_dp_dbad [8];
  bit [WSMIDPDWIDPERDW:0] local_dp_dwid [8];
  bit [63:0]              local_dp_data [8];
  bit [63:0]              rand_data, data_bit_mask[8];
  
  initiator_beat_aligned_addr = cfg.align(smi_addr,initiator_intfsize_in_bytes);
  `uvm_info(get_type_name(),$sformatf("::set_data_fields:: initiator_beat_aligned_addr :%0h",initiator_beat_aligned_addr),UVM_DEBUG)

  if(smi_msg_type == CMD_CMP_ATM) begin
    align_compare_atomic(min_be_bit,max_be_bit);
    all_BE_on = 1;
  end
  else begin
    min_be_bit = (smi_addr - initiator_beat_aligned_addr);      
    max_be_bit = min_be_bit + payload_size_in_bytes; // min + req_length
  end

  `uvm_info(get_type_name(),
            $sformatf("::set_data_fields:: smi_size:0x%0h addr:0x%0h beat_addr:0x%0h min_be_bit:0x%0d max_be_bit:0x%0d smi_msg_type :%0h",
                      smi_size,smi_addr,
                      cfg.align(smi_addr,initiator_intfsize_in_bytes),min_be_bit,max_be_bit,smi_msg_type), UVM_HIGH)

  initiator_intfsize_in_bytes  = initiator_intfsize_in_dwords*8;

  `uvm_info(get_type_name(),$sformatf("::set_data_fields:: initiator_intfsize_in_bytes :%0d,num_payload_bytes:%0d",initiator_intfsize_in_bytes,num_payload_bytes),UVM_HIGH)
  //Determine Data Word iterator limits
  dwid   = (initiator_beat_aligned_addr/8)%8;

  if(payload_size_in_bytes > initiator_intfsize_in_bytes)begin
    local_smi_addr  = ((smi_addr >>smi_size)<<smi_size); //Align address to payload
    `uvm_info(get_type_name(),$sformatf("::set_data_fields:: smi_addr :%0h local_smi_addr :%0h smi_size :%0d ",smi_addr,local_smi_addr,smi_size),UVM_DEBUG)
    dwid_l = local_smi_addr[5:3];
    dwid_h = dwid_l+(payload_size_in_bytes/8)-1;
  end
  else begin
    local_smi_addr  = ((smi_addr >>(3+smi_intfsize))<<(3+smi_intfsize)); //Align address to initiator AIU interface
    `uvm_info(get_type_name(),$sformatf("::set_data_fields:: smi_addr :%0h local_smi_addr :%0h smi_intfsize :%0d ",smi_addr,local_smi_addr,smi_intfsize),UVM_DEBUG)
    dwid_l = local_smi_addr[5:3];
    dwid_h = dwid_l+initiator_intfsize_in_dwords-1;
  end
  if(args.k_all_byte_enables_on) begin
    all_BE_on = 1;
  end
  else if(!all_BE_on) begin 
    all_BE_on = $urandom;
  end
  `uvm_info(get_type_name(),$sformatf("::set_data_fields:: dwid :%0d dwid_l :%0d dwid_h :%0d be_mode:%0d",dwid,dwid_l,dwid_h,all_BE_on),UVM_DEBUG)

  for(int cycle_itr=0; cycle_itr < num_dtw_cycles; cycle_itr++) begin
    for(int intf_itr= 0; intf_itr< 2**smi_intfsize;intf_itr++)begin
      assert(std::randomize(rand_data))
      else begin
        `uvm_error(get_type_name(), "::set_data_fields:: Failure to randomize data")
      end
      //deassert_be = $urandom_range(1,100) < 10 && args.k_smi_dtw_err; FIXME-priority-3 disabled plusargs
      //`uvm_info(get_type_name(),$sformatf("::set_data_fields:: for DTW_DATA_CLN,DTW_DATA_DTY  deassert_be :%b",deassert_be),UVM_DEBUG); FIXME-priority-3 disabled plusargs
      ///////////////////////////////////////////////////
      // Setting BE for Write Data
      //////////////////////////////////////////////////
      for(int byte_itr=0; byte_itr < 8; byte_itr++) begin
         if(smi_msg_type inside {DTW_NO_DATA}) begin
            local_dp_be[dwid_itr][byte_itr] = 0;
         end
         else if(smi_msg_type inside {DTW_DATA_CLN,DTW_DATA_DTY}) begin
           if(deassert_be) begin 
             local_dp_be[dwid_itr][byte_itr] = 0;
           end
           else begin
             local_dp_be[dwid_itr][byte_itr] = 1;
           end
         end
         else begin
            if((be_counter >= min_be_bit) && (be_counter < max_be_bit)) begin // Enforce Byte Enable bit range
              if(args.k_alternate_be)begin //Alternate Byte Enables Case
                local_dp_be[dwid_itr][byte_itr] = ~prev_BE_val;
                prev_BE_val = local_dp_be[dwid_itr][byte_itr];
              end
              else begin
                //FIXME-priority-1 What is this special constraint?
                if((smi_msg_type == DTW_DATA_PTL || cfg.isDtwMrgMrd(smi_msg_type)) && (smi_size >2))begin
                  local_dp_be[dwid_itr][byte_itr] = all_BE_on ? 1 : $urandom_range(1,0);
                end
                else begin //Normal Case
                 local_dp_be[dwid_itr][byte_itr] = 1;
                end
              end
           end
           else begin
              local_dp_be[dwid_itr][byte_itr] = 0;
           end
         end
         if (args.k_random_dbad_on_dtw_req) begin //FIXME-priority-4 Can this be more distributed or is this adequate?
           local_dp_dbad[cycle_itr+intf_itr] = $random;
           `uvm_info(get_type_name(),
                   $sformatf("::set_data_fields:: randomizing poison field | dbad[%0d]=0x%0h",dwid_itr,local_dp_dbad[dwid_itr]), UVM_DEBUG)
         end
         be_counter += 1;
         `uvm_info(get_type_name(),
                   $sformatf("::set_data_fields:: be_counter=0x%0d be[%0d][%0d]=0x%0h",
                              be_counter,dwid_itr,byte_itr,local_dp_be[dwid_itr][byte_itr]), UVM_DEBUG)
      end
      `uvm_info(get_type_name(),
                $sformatf("::set_data_fields:: be[%0d]=0x%0h", dwid_itr,local_dp_be[dwid_itr]), UVM_DEBUG)
      for(int byte_itr=0; byte_itr < 8; byte_itr++) begin
        data_bit_mask[dwid_itr][byte_itr*8+:8] = {8{local_dp_be[dwid_itr][byte_itr]}};
      end
      dwid_itr++;
      ///////////////////////////////////////////////////
      // Setting Dwid for Write Data
      //////////////////////////////////////////////////
      //if(dwid_counter < dwid_itr)begin What is this achieving in the old seq?  Doesn't translate, avoiding in the new one FIXME
      local_dp_dwid[(cycle_itr*initiator_intfsize_in_dwords)+intf_itr] = dwid;
      local_dp_data[(cycle_itr*initiator_intfsize_in_dwords)+intf_itr] = rand_data; // FIXME DO we need to mask payload isn't that byte enables job?& data_bit_mask[dwid_itr];
      dwid++;
      //dwid_counter++; FIXME
      if((payload_size_in_bytes > 8) && (dwid > dwid_h)) begin //Reset Data Word iterator for next cycle
        dwid = dwid_l; 
      end
      `uvm_info(get_type_name(), $sformatf("::set_data_fields:: dwid[%0d][%0d]=0x%0h", 
                cycle_itr,intf_itr,local_dp_dwid[cycle_itr*initiator_intfsize_in_dwords+intf_itr]), UVM_DEBUG)
      //end
    end
  end

  if(payload_size_in_bytes < initiator_intfsize_in_bytes)begin
    if(smi_msg_type == CMD_CMP_ATM && !args.k_atomic_directed)begin
       num_payload_bytes = payload_size_in_bytes/2;
       smi_addr[$clog2(num_payload_bytes)] = $urandom_range(0,1);
    end
  end

  foreach(local_dp_data[i])begin
    `uvm_guarded_info(args.k_stimulus_debug,get_type_name(),$sformatf("::set_data_fields:: local_dp_data[%0d] :%0x",i,local_dp_data[i]),UVM_DEBUG)
    `uvm_guarded_info(args.k_stimulus_debug,get_type_name(),$sformatf("::set_data_fields:: local_dp_be[%0d]   :%0b",i,local_dp_be[i]),UVM_DEBUG)
    `uvm_guarded_info(args.k_stimulus_debug,get_type_name(),$sformatf("::set_data_fields:: local_dp_dwid[%0d] :%0x",i,local_dp_dwid[i]),UVM_DEBUG)
    `uvm_guarded_info(args.k_stimulus_debug,get_type_name(),$sformatf("::set_data_fields:: local_dp_dbad[%0d] :%0x",i,local_dp_dbad[i]),UVM_DEBUG)
  end

  if((num_dtw_cycles*(initiator_intfsize_in_dwords)*64) < WDATA) begin 
    smi_dp_size = 1;
  end
  else begin
    smi_dp_size = (num_dtw_cycles*(initiator_intfsize_in_dwords)*64)/WDATA;
  end
  `uvm_info(get_type_name(),$sformatf("::set_data_fields:: num_dtw_cycles :%0d (2**smi_intfsize)*64 :%0d WDATA :%0d  smi_dp_size :%0d",
                                        num_dtw_cycles,(initiator_intfsize_in_dwords)*64,WDATA,smi_dp_size),UVM_DEBUG)

  smi_dp_be     = new[smi_dp_size];
  smi_dp_dwid   = new[smi_dp_size];
  smi_dp_data   = new[smi_dp_size];
  smi_dp_dbad   = new[smi_dp_size];

  foreach(smi_dp_data[i])begin
   for(int j = 0; j< WDATA/64;j++)begin
    smi_dp_be[i][j*8+:8]                               =  local_dp_be[i*(WDATA/64)+j];
    smi_dp_dwid[i][j*WSMIDPDWIDPERDW+:WSMIDPDWIDPERDW] =  local_dp_dwid[i*(WDATA/64)+j];
    smi_dp_data[i][j*64+:64]                           =  local_dp_data[i*(WDATA/64)+j];
    smi_dp_dbad[i][j]                                  =  local_dp_dbad[i*(WDATA/64)+j];
    end
  end
  
  foreach(smi_dp_data[i])begin
    `uvm_info(get_type_name(),$sformatf("::set_data_fields:: smi_dp_data[%0d] :%0x",i,smi_dp_data[i]),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("::set_data_fields:: smi_dp_be[%0d]   :%0b",i,smi_dp_be[i]),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("::set_data_fields:: smi_dp_dwid[%0d] :%0x",i,smi_dp_dwid[i]),UVM_HIGH)
    `uvm_info(get_type_name(),$sformatf("::set_data_fields:: smi_dp_dbad[%0d] :%0b",i,smi_dp_dbad[i]),UVM_HIGH)
  end
endfunction



function data_seq_item::assign_address();
  int is_coh_read;
  
  if(smi_msg_type inside {mrd_types}) begin
    is_coh_read = 1; 
  end
  if(!abort_addr_gen) begin
    <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
    bit permit_SP = ($urandom_range(1,100) <= args.wt_sp_addr_range.get_value());
    bit permit_EX = smi_es && (args.k_force_exclusive==1);
    bit atomic_with_all_ways_rsvd_for_SP = (cfg.sp_ways_rsvd == CCP_WAYS) && (cfg.isAtomics(smi_msg_type));
    //If your address is atomics and all ways are reserved for SP then force atomics to go only to SP address
    `uvm_guarded_info(args.k_stimulus_address_debug,get_type_name(),$sformatf("::assign_address:: sp_exists:%0b avoid_SCP_addr:%0b permit_EX:%0b permit_SP:%0b ways_rsvd:%0d atomic:%0b max_ways:%0d msgType:%0h",
            cfg.sp_exists, avoid_SCP_addr, permit_EX, permit_SP, cfg.sp_ways_rsvd, atomic_with_all_ways_rsvd_for_SP, CCP_WAYS, smi_msg_type),UVM_HIGH)
    if(cfg.sp_exists && !avoid_SCP_addr && !permit_EX && (permit_SP || atomic_with_all_ways_rsvd_for_SP)) begin
      gen_SP_addr = cfg.m_rsrc_mgr.get_SP_addr();
      gen_addr = ncoreConfigInfo::gen_full_cache_addr_from_spad_addr(gen_SP_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
    end
    else begin
    <%}%>
      gen_addr = cfg.m_rsrc_mgr.get_addr({smi_msg_type,m_pattern_type,m_addr_type,align_size},is_coh_read);
      if(cfg.sp_exists) begin
        smi_addr_t caddy;
        //Reset the interleaved dmi field. Avoid same CL collisions by not sending illegal addresses.
        caddy = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(gen_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
        gen_addr = ncoreConfigInfo::gen_full_cache_addr_from_spad_addr(caddy,<%=obj.DmiInfo[obj.Id].nUnitId%>);
      end
    <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
    end
    <%}%>

    if(smi_es && (cfg.exclusive_monitor_size==0)) begin 
      noncoh_non_CA_EX = 1;
      `uvm_info(get_type_name(),$sformatf("::set_data_fields:: NONCOH non-cacheable exclusive"),UVM_HIGH)
    end
    if(cfg.sp_exists & cfg.isSpAddrAfterTranslate(gen_addr)) begin
      gen_addr_is_SP = 1;
    end
    /* FIXME
    else begin
      gen_addr[($clog2(N_SYS_CACHELINE)-1):0] = 0;
      gen_addr += $urandom_range(N_SYS_CACHELINE-1,0);
    end*/
    smi_addr = gen_addr;
  <%if (obj.wSecurityAttribute > 0){%>
    if(gen_addr_is_SP && cfg.sp_exists) begin
      smi_ns = cfg.sp_ns; //Top-down NS bit propagation
    end
  <% } %>
  end
endfunction

function int data_seq_item::get_align_size();
  int m_size;
  if (args.k_force_align_addr) begin
    m_size = args.k_force_align_addr;
  end
  else if (smi_es || smi_msg_type == CMD_CMP_ATM || (num_payload_bytes < initiator_intf_size_in_bytes) ) begin
    m_size = num_payload_bytes;
    `uvm_guarded_info(args.k_stimulus_debug,get_type_name(),$sformatf("::set_data_fields:: Picking regular alignment for align_size:%0d", m_size),UVM_DEBUG)
  end
  else begin
    m_size = initiator_intf_size_in_bytes;
    `uvm_guarded_info(args.k_stimulus_debug,get_type_name(),$sformatf("::set_data_fields:: Picking AIU alignment for align_size:%0d",m_size),UVM_DEBUG)
  end
  return(m_size);
endfunction 

function data_seq_item::align_address();
  if(!args.k_atomic_directed) begin
    smi_addr = (smi_addr/align_size)*align_size;
  end
  `uvm_info(get_type_name(),$sformatf("::set_data_fields:: smi_addr:%0h , align_size:%0d", smi_addr, align_size),UVM_DEBUG)
endfunction : align_address

function data_seq_item::set_data_guidance();
  //Hooks to help determine number of cycles needed to transfer data. 
  //Depends on AIU interface size and payload size.
  beatn   = (smi_addr[BEAT_INDEX_HIGH:BEAT_INDEX_LOW])<<BEAT_INDEX_LOW;

  num_dtw_cycles_smi = $ceil(real'((beatn % (2**BEAT_INDEX_LOW)) + num_payload_bytes) /
                             real '(2**BEAT_INDEX_LOW));

  initiator_intf_size_in_bytes = (2**smi_intfsize)*8;
  
  if(num_payload_bytes <= initiator_intf_size_in_bytes) begin
    num_dtw_cycles = 1;
  end
  else begin
    num_dtw_cycles = num_payload_bytes/initiator_intf_size_in_bytes;
  end
  
  `uvm_info(get_type_name(),$sformatf("::set_data_guidance:: initiator_intf_size_in_bytes :%0d,num_payload_bytes:%0d num_dtw_cycles:%0d",
                                        initiator_intf_size_in_bytes,num_payload_bytes,num_dtw_cycles),UVM_HIGH)
endfunction : set_data_guidance

function data_seq_item::set_intfsize();
  //Pick legal interface size depending on AIU chosen.
  `ifdef DATA_ADEPT      
    if(args.k_intfsize >2)begin
      if(smi_msg_type == CMD_CMP_ATM) begin
        smi_intfsize = cfg.allowedIntfSizeActual[aiu_gen_id.aiu_id];
      end
      else begin
        smi_intfsize   = cfg.allowedIntfSize[aiu_gen_id.aiu_id];
      end
    end
    else begin
      smi_intfsize   = args.k_intfsize;
    end
  `else
    smi_intfsize   = $clog2(WSMIDPBE/8);
  `endif
  `uvm_info(get_type_name(), $sformatf("::set_intfsize:: AIU_ID:%0h k_intfsize :%0d smi_intfsize:%0d",aiu_gen_id.aiu_id, args.k_intfsize, smi_intfsize),UVM_HIGH)
endfunction : set_intfsize

function data_seq_item::set_payload_size();
  smi_size = $clog2(num_payload_bytes);
  smi_mpf1_asize = $clog2(num_payload_bytes);
  smi_mpf1_alength = 0; // FIXME-priority-10
endfunction : set_payload_size
