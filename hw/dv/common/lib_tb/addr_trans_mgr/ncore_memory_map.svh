
<% var aiu;if((obj.testBench === "fsys") || (obj.testBench === "cust_tb") || (obj.testBench == "emu")) {    aiu = obj.AiuInfo[obj.Id];} else {    aiu = obj.DutInfo;}%>
<% 
var _child_blkid = [];
var chiaiu_idx = 0;
var ioaiu_idx = 0;

if((obj.testBench === "fsys") || (obj.testBench === "cust_tb") || (obj.testBench == "emu")) {
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')) {
      _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
      chiaiu_idx++;
    } else {
      _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
      ioaiu_idx++;
    }
  }
} else {
  _child_blkid[0] = obj.BlockId;
}

%>
                     
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Class : ncore_memory_map
// Description : Ncore 3.0 onwards, Dynamic configuration of Memory map is possible 
//               by programming CSRs. This class porvides an interface to either 
//               randomly create a memory map by applying user provided constraints,
//               if any, or reads the build time configuration information provided
//               into the configuration. 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
//import "DPI-C" function string getenv(input string env_name);

class ncore_memory_map extends uvm_object;
  rand int dmi_ig_id;  // AMIGR regiser
  rand int dmi_MIG2AIFId  ; //MIFSR register
  rand int dmi_MIG3AIFId  ;
  rand int dmi_MIG4AIFId  ;
  rand int dmi_MIG8AIFId  ;
  rand int dmi_MIG16AIFId ;

  int min_memregions, max_memregions;

  int dmi_grps[$];
  int dii_grps[$];

  int nintrlv_grps[$];
  ncoreConfigInfo::ncore_unit_type_t nintrlv_type[$];

  int grps_memregion[][$];

  int coh_regq[$];
  int iocoh_regq[$];
  int noncoh_regq[$];
  int nrs_regq[$];   // exact one element
  int boot_regq[$];  // exact one element
  int noncoh_reg_maps_to_dii;
  bit test_connectivity_test;
  string new_nrs="";
  string old_nrs="";

  constraint c_dmi_ig_id {
    //TODO: always pick 1st MIGS until DMI interleaving is supported by DV. In configs, make sure 1st MIGS has no DMI interleaving.
    //dmi_ig_id inside {[0:ncoreConfigInfo::intrlvgrp_vector.size() - 1]};
    <%if ((obj.testBench == "fsys") || (obj.testBench === "cust_tb") || (obj.testBench == "emu")) { %>
      dmi_ig_id inside {[0:$size(ncoreConfigInfo::intrlvgrp_vector) - 1]};
    <% } else { %>
      dmi_ig_id inside {[0:0]};
    <% } %>
  }

  constraint c_dmi_if_id { //MIFSR register  // use only AiuInfo[0] because same for all agents 
    <%if ((obj.testBench == "fsys") || (obj.testBench === "cust_tb") || (obj.testBench == "emu")) { %>
      dmi_MIG2AIFId  inside {[0:<%=(obj.AiuInfo[0].InterleaveInfo.dmi2WIFV.length >0)?obj.AiuInfo[0].InterleaveInfo.dmi2WIFV.length -1:0%>]};
      dmi_MIG3AIFId  inside {[0:<%=(obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length >0)?obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length -1:0%>]};
      dmi_MIG4AIFId  inside {[0:<%=(obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length >0)?obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length -1:0%>]};
      dmi_MIG8AIFId  inside {[0:<%=(obj.AiuInfo[0].InterleaveInfo.dmi8WIFV.length >0)?obj.AiuInfo[0].InterleaveInfo.dmi8WIFV.length -1:0%>]};
      dmi_MIG16AIFId inside {[0:<%=(obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length>0)?obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length -1:0%>]};
    <% } else { %>
      // to be compliant with legacy simulation. Unit never setup MIFSR register
      dmi_MIG2AIFId  inside {[0:0]}; //MIFSR register
      dmi_MIG3AIFId  inside {[0:0]};
      dmi_MIG4AIFId  inside {[0:0]};
      dmi_MIG8AIFId  inside {[0:0]};
      dmi_MIG16AIFId inside {[0:0]};
    <% } %>
  }

  extern function new(string name = "ncore_memory_map");

  //gen_new_cacheline interface
  extern function int get_rand_memregion(ncoreConfigInfo::addr_format_t mem_type, int agentid =-1);
  extern function bit[63:0] lbound(int mid);
  extern function bit[63:0] ubound(int mid);
  extern function ncoreConfigInfo::sel_bits_t get_port_sel_bits(
    int logical_id,
    ncoreConfigInfo::ncore_unit_type_t utype);

  extern function ncoreConfigInfo::intq get_coh_mem_regions();
  extern function ncoreConfigInfo::intq get_iocoh_mem_regions();
  extern function ncoreConfigInfo::intq get_noncoh_mem_regions();
  extern function ncoreConfigInfo::intq get_nrs_regions();
  extern function ncoreConfigInfo::intq get_boot_regions();
   
  extern function string convert2string();

  //
  //Internal methods
  //

  extern function void pre_randomize();
  extern function void post_randomize();
  extern function void append_memmap_info();
  extern function void add_memorder_info();
  extern function void add_noncoh_info();
  extern function void add_security_info();
  extern function int  pick_smallest_memregion_size(int ig_set_idx);
  extern function void fill_memregions_info();

  extern function int low_ordr_region(int val);
  extern function int hgh_ordr_region(int val);
  extern function int count_ones(bit [63:0] val);

  extern function void pick_regions();
  extern function ncoreConfigInfo::intq pick_regions_assoc2targetid(int agentid);
  //Local becuase of the order dependency of invoking the functions
  extern local function ncoreConfigInfo::intq pick_noncoh_regions();
  extern local function ncoreConfigInfo::intq pick_iocoh_regions();
  extern local function ncoreConfigInfo::intq pick_coh_regions();
  extern local function ncoreConfigInfo::intq pick_nrs_regions();
  extern local function ncoreConfigInfo::intq pick_boot_regions();

endclass: ncore_memory_map

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : new
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncore_memory_map::new(string name = "ncore_memory_map");

endfunction: new

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pre_randomize
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void ncore_memory_map::pre_randomize();
  `ASSERT(max_memregions >= min_memregions);

  //Constraint on minimum number of DMI grps required
  `ASSERT(max_memregions <= 32);
  `ASSERT(max_memregions <= ncoreConfigInfo::get_sfi_addr_width(0) - 1 - 12);
endfunction: pre_randomize

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : post_randomize
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void ncore_memory_map::post_randomize();
  //Randomization helper classes
  memregions_per_ig m_reg_p_ig;
  memregions_info   m_reg_info;
  int dmi_igs, dii_igs;
  string s;
  int gpra_mem_size = 0;
  integer outfile;
  string line,addr,regi;
  int num,mem_per_ig_num[$];
  string ext_mem_path;

  //CONC-14531 : If config with small addr width uses certain plusargs(that change size[i] array),
  // then use the MAX variable to configure size[] array value to avoid rondomizer conflicts
  int MAX = ncoreConfigInfo::MIN_ADDR_WIDTH > 43 ?
                     44 : ncoreConfigInfo::MIN_ADDR_WIDTH;


  if($test$plusargs("program_nrs_base")) begin
      $value$plusargs("program_nrs_base=%b", ncoreConfigInfo::program_nrs_base);

      foreach(ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]) begin
      bit en_bit_change_val=0;
        if(i==0) old_nrs=$psprintf("Old NRSBASE for AIUs : '{");
        old_nrs = $psprintf("%s 0x%16h",old_nrs,ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]);
        if(i==($size(ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU)-1)) old_nrs=$psprintf("%s}\n",old_nrs);
        else old_nrs=$psprintf("%s,",old_nrs); 
        for(int x=0;x<32;x=x+1) begin
          if(ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i][x]==1 || en_bit_change_val==1) begin
            ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i][x] = $urandom(); 
            en_bit_change_val = 1;
          end
        end
        if(i==0) new_nrs=$psprintf("New NRSBASE for AIUs : '{");
        new_nrs = $psprintf("%s 0x%16h",new_nrs,ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]);
        if(i==($size(ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU)-1)) new_nrs=$psprintf("%s}\n",new_nrs);
        else new_nrs=$psprintf("%s,",new_nrs); 
      end
  end

  m_reg_p_ig = new();
  m_reg_info = new();
  dmi_igs = 0;
  dii_igs = 0;

  $value$plusargs("use_dmi_ig_id=%d", dmi_ig_id);
  if(dmi_ig_id >= $size(ncoreConfigInfo::intrlvgrp_vector))
    dmi_ig_id = $size(ncoreConfigInfo::intrlvgrp_vector) - 1;
  ncoreConfigInfo::picked_dmi_igs = dmi_ig_id;
 
 $value$plusargs("use_dmi_MIG2AIFId=%d", dmi_MIG2AIFId);   
 $value$plusargs("use_dmi_MIG3AIFId=%d", dmi_MIG3AIFId);   
 $value$plusargs("use_dmi_MIG4AIFId=%d", dmi_MIG4AIFId);   
 $value$plusargs("use_dmi_MIG8AIFId=%d", dmi_MIG8AIFId);   
 $value$plusargs("use_dmi_MIG16AIFId=%d", dmi_MIG16AIFId);  
if (dmi_MIG2AIFId >= <%=obj.AiuInfo[0].InterleaveInfo.dmi2WIFV.length%>) begin
   dmi_MIG2AIFId = <%=(obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length)?obj.AiuInfo[0].InterleaveInfo.dmi2WIFV.length-1:0%>;
end
if (dmi_MIG3AIFId >= <%=obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length%>) begin
   dmi_MIG3AIFId = <%=(obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length)?obj.AiuInfo[0].InterleaveInfo.dmi3WIFV.length-1:0%>;
end
if (dmi_MIG4AIFId >= <%=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length%>) begin
   dmi_MIG4AIFId = <%=(obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length)?obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length-1:0%>;
end
if (dmi_MIG8AIFId >= <%=obj.AiuInfo[0].InterleaveInfo.dmi8WIFV.length%>) begin
   dmi_MIG8AIFId = <%=(obj.AiuInfo[0].InterleaveInfo.dmi8WIFV.length)?obj.AiuInfo[0].InterleaveInfo.dmi8WIFV.length-1:0%>;
end
if (dmi_MIG16AIFId >= <%=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length%>) begin
   dmi_MIG16AIFId = <%=(obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length)?obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length-1:0%>;
end
ncoreConfigInfo::picked_dmi_if[2]= dmi_MIG2AIFId;
ncoreConfigInfo::picked_dmi_if[3]= dmi_MIG3AIFId;
ncoreConfigInfo::picked_dmi_if[4]= dmi_MIG4AIFId;
ncoreConfigInfo::picked_dmi_if[8]= dmi_MIG8AIFId;
ncoreConfigInfo::picked_dmi_if[16] = dmi_MIG16AIFId;

  foreach (ncoreConfigInfo::intrlvgrp_vector[dmi_ig_id][idx]) 
    dmi_grps.push_back(ncoreConfigInfo::intrlvgrp_vector[dmi_ig_id][idx]);
  for (int i = 0; i < ncoreConfigInfo::NUM_DIIS-1; ++i)
    dii_grps.push_back(1);

  //Append regions into nintrlv_grps queue
  foreach (dmi_grps[i]) begin
    nintrlv_grps.push_back(dmi_grps[i]);
    nintrlv_type.push_back(ncoreConfigInfo::DMI);
  end

  foreach (dii_grps[i]) begin
    nintrlv_grps.push_back(dii_grps[i]);
    nintrlv_type.push_back(ncoreConfigInfo::DII);
  end

  //min_memregions is constrained in post_randomize phase because
  //size of nintrlv_grps is determined in randomize phase
  min_memregions = ncoreConfigInfo::NGPRA;
  max_memregions = ncoreConfigInfo::NGPRA;

  `uvm_info("ADDR MGR", $psprintf("NGPRA: %0d dmi_grps.size: %0d dii_grps.size: %0d", ncoreConfigInfo::NGPRA, dmi_grps.size(), dii_grps.size()), UVM_MEDIUM)

    if (max_memregions > 32)
      `uvm_error("ADDR MGR", $psprintf("memory_regions: %0d Max limit is 32",
          ncoreConfigInfo::NGPRA))
/*  FIXME - Khaleel says system does not have this constraint
    if (nintrlv_grps.size() + 1 > ncoreConfigInfo::NGPRA)
      `uvm_error("ADDR MGR", {$psprintf("nGPRA: %0d Groups: %0d",
          ncoreConfigInfo::NGPRA, nintrlv_grps.size() + 1), 
          " nGPRA must be >= DMI MIG's + nDII's + 1 (non-coh region)"})
*/   
    if (nintrlv_grps.size() > ncoreConfigInfo::NGPRA)
      `uvm_error("ADDR MGR", {$psprintf("nGPRA: %0d Groups: %0d",
          ncoreConfigInfo::NGPRA, nintrlv_grps.size()), 
          " nGPRA must be >= DMI MIG's + nDII's"})

   foreach (nintrlv_grps[i]) 
      $sformat(s, "%s %0d", s, nintrlv_grps[i]);

      $sformat(s, "%s \n", s);

   foreach (nintrlv_type[i]) 
      $sformat(s, "%s %s", s, nintrlv_type[i].name);
   
  `uvm_info("ADDR MGR", $psprintf("%0s",s), UVM_LOW)

  `uvm_info("ADDR MGR",
      $psprintf("dmi_ig_id: %0d min_memregions: %0d max_memregions: %0d nintrlv_grps: %0d",
      dmi_ig_id, min_memregions, max_memregions, nintrlv_grps.size()),
      UVM_NONE)

  m_reg_p_ig.min_memregions = min_memregions;
  m_reg_p_ig.max_memregions = max_memregions;
  m_reg_p_ig.ig_sets        = nintrlv_grps;

  //Randomize number of memory regions and assign memory
  //regions to each IG-set..
  if ($test$plusargs("one_memregion_by_aiu"))begin
  int ig0_size = (ncoreConfigInfo::NGPRA < <%=obj.nAIUs+1%>)?ncoreConfigInfo::NGPRA:<%=obj.nAIUs+1%>;
  `ASSERT(m_reg_p_ig.randomize() with {memregions_per_ig[0] == ig0_size;}); // in case of newperf_test use one  DMI region by AIU 
  end else if ($test$plusargs("override_memregions"))begin // use this plusarg only when need to reconfigure address map and also provide an external file path
        <%if(obj.enInternalCode){%>
            <%if(obj.mem_file_path && obj.mem_file_path !== ""){%>
                ext_mem_path = "<%=obj.mem_file_path%>";
            <%}else{%>
                <%if(obj.CDN){%>
                    ext_mem_path = {getenv("PROJ_HOME"), "/tb/xsim/sanity/memregions.txt"};
                <%}else{%>
                    ext_mem_path = {getenv("PROJ_HOME"), "/tb/vcs/sanity/memregions.txt"};
                <%}%>
            <%}%>
        <%}else{%>
            <%if(obj.CDN){%>
                ext_mem_path = {getenv("PROJ_HOME"), "/tb/xsim/memregions.txt"};
            <%}else{%>
                ext_mem_path = {getenv("PROJ_HOME"), "/tb/vcs/memregions.txt"};
            <%}%>
        <%}%>
        outfile=$fopen(ext_mem_path,"r");
    void'($fgets(line,outfile));
    void'($fgets(line,outfile));
    void'($fscanf(outfile,"%s:",line));
    for(int j=0;j < nintrlv_grps.size();j++) begin
      void'($fscanf(outfile,"%d",num));    // here configuring Number_of_interleaved_memory_regions_associated_per_IG
      mem_per_ig_num.push_back(num);
    end

    `ASSERT(m_reg_p_ig.randomize() with { foreach (memregions_per_ig[i]) { memregions_per_ig[i]==mem_per_ig_num[i];}}); // in case of override region by user
  end else if($test$plusargs("conc_17519")) begin
    `ASSERT(m_reg_p_ig.randomize() with { foreach (memregions_per_ig[i]) { memregions_per_ig[i]==(((<%=obj.AiuInfo[0].nGPRA%>-4)*i) + 2);}});
  end else if($test$plusargs("conc_17605")) begin
    `ASSERT(m_reg_p_ig.randomize() with { foreach (memregions_per_ig[i]) { memregions_per_ig[i]==4;}});
  end else begin
      `ASSERT(m_reg_p_ig.randomize());
  end

  m_reg_p_ig.print();

  grps_memregion = new [nintrlv_grps.size()];

  foreach (nintrlv_grps[i]) begin
    for (int j = 0; j < m_reg_p_ig.memregions_per_ig[i]; ++j)
      grps_memregion[i].push_back(m_reg_p_ig.unq_val.pop_front());
  end

  m_reg_info.nmemregions = ncoreConfigInfo::NGPRA;
  for (int i = 0; i < ncoreConfigInfo::NGPRA; ++i) 
    m_reg_info.memrg2ig_map.push_back(0);  
  foreach (grps_memregion[i]) begin
    foreach (grps_memregion[i][j]) begin
      m_reg_info.memrg2ig_map[grps_memregion[i][j]] = nintrlv_grps[i];
    end
  end
  if (MAX <= 32) MAX = 28;
  else MAX = 30;
  //Generate Random memory region boundaries foeach memory region
  if($test$plusargs("dce_fix_index") || $test$plusargs("dmi_fix_index") || $test$plusargs("en_excl_txn") || $test$plusargs("en_excl_noncoh_txn")) begin
        <%if(obj.testBench == "chi_aiu") { %>
           if($test$plusargs("pick_boundary_addr") && ($test$plusargs("memregion_min_size") || $test$plusargs("memregion_rand_size"))) begin
             `ASSERT(m_reg_info.randomize());
           end else begin
             `ASSERT(m_reg_info.randomize() with {foreach(size[i]) size[i] > (1<<MAX);});
           end
        <% } else { %>
             `ASSERT(m_reg_info.randomize() with {foreach(size[i]) size[i] > (1<<MAX);});
        <% } %>
  end else begin
     `ASSERT(m_reg_info.randomize());
  end
  m_reg_info.print();

  <%if(obj.testBench == "chi_aiu") { %>
  if ($test$plusargs("pick_boundary_addr") && $test$plusargs("hw_cfg_41_cov")) begin
      if (!$test$plusargs("memregion_rand_size")) begin
          $value$plusargs("gpra_mem_size=%d", gpra_mem_size);
      end else begin
          gpra_mem_size = $urandom_range(1,30);
      end
  end
  <% } %>

  foreach (m_reg_info.st_addr[i]) begin
    ncoreConfigInfo::memregion_boundaries_t info;
    <%if(obj.testBench == "chi_aiu") { %>
    if ($test$plusargs("pick_boundary_addr") && $test$plusargs("hw_cfg_41_cov")) begin
      m_reg_info.size[i] = ('h1000*m_reg_info.memrg2ig_map[i]) << gpra_mem_size;
    end
    <% } %>
    info.start_addr = m_reg_info.st_addr[i];
    info.end_addr   = m_reg_info.st_addr[i] + m_reg_info.size[i];
    ncoreConfigInfo::memregion_boundaries.push_back(info);
  end

  //IG Port select bits
  //Add runtime information related to DII & DMI
  //to Ncore Configuration D.S 
  append_memmap_info();
  pick_regions();
  add_memorder_info(); 
  add_noncoh_info(); 
  add_security_info(); 
  fill_memregions_info();
endfunction: post_randomize

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : append_memmap_info
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void ncore_memory_map::append_memmap_info();
  int agentid = ncoreConfigInfo::NUM_AIUS + ncoreConfigInfo::NUM_DCES + ncoreConfigInfo::NUM_DVES;
  if (ncoreConfigInfo::NUM_DMIS) begin
    foreach (dmi_grps[idx]) begin
      int q[$];
      ncoreConfigInfo::logical2dmi_map.push_back(q);
      ncoreConfigInfo::logical2dmi_prt.push_back(q);
      ncoreConfigInfo::intrlvgrp_if.push_back(ncoreConfigInfo::DMI);
    end
  end

  if (ncoreConfigInfo::NUM_DIIS) begin
    foreach (dii_grps[idx]) begin
      int q[$];
      ncoreConfigInfo::logical2dii_map.push_back(q);
      ncoreConfigInfo::logical2dii_prt.push_back(q);
      ncoreConfigInfo::intrlvgrp_if.push_back(ncoreConfigInfo::DII);
    end
  end

  foreach (grps_memregion[i]) begin
    int q[$];
    foreach (grps_memregion[i][j])
      q.push_back(grps_memregion[i][j]);
    ncoreConfigInfo::intrlvgrp2mem_map.push_back(q);
  end

  foreach (nintrlv_grps[idx]) begin
    int count, didx;
    count = 0;
    didx  = 0;
    for (int i = 0; i < nintrlv_grps[idx]; i++) begin

      if (nintrlv_type[idx] == ncoreConfigInfo::DMI) begin
        ncoreConfigInfo::logical2dmi_map[idx].push_back(agentid++);
        ncoreConfigInfo::logical2dmi_prt[idx].push_back(count++);
      end else begin
        ncoreConfigInfo::logical2dii_map[didx].push_back(agentid++);
        ncoreConfigInfo::logical2dii_prt[didx].push_back(count++);
        didx++;
      end
    end 
  end
endfunction: append_memmap_info

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : add_noncoh_info
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void ncore_memory_map::add_noncoh_info();
  int ig;
  int idx;
//#Stimulus.FSYS.GPRAR.NC_zero
//#Stimulus.FSYS.GPRAR.NC_one
   for( ig=0; ig<ncoreConfigInfo::intrlvgrp2mem_map.size(); ig=ig+1) begin:_ig
       for( idx=0; idx<ncoreConfigInfo::intrlvgrp2mem_map[ig].size(); idx=idx+1) begin:_idx
          if(ncoreConfigInfo::intrlvgrp_if[ig] == ncoreConfigInfo::DII) begin:_dii
        //#Stimulus.FSYS.address_dec_error.illegalDII.access #Stimulus.IOAIU.CoherentDIIAccess.DECERR
                   if ($test$plusargs("coherent_dii")) begin
                     ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(0);
                  end else begin
                    //#Stimulus.FSYS.dii_noncoh_txn
                      ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(1);
                   end
       		end:_dii
       		if(ncoreConfigInfo::intrlvgrp_if[ig] == ncoreConfigInfo::DMI) begin:_dmi
              bit pcie_prod_consu_stress_test;
              $value$plusargs("pcie_prod_consu_stress_test=%0b",pcie_prod_consu_stress_test);

			  //when below plusarg is used, mark wt_ace_wrunq and wt_ace_rdonce as 0, since no coherent traffic is possible
              if ($test$plusargs("pcie_prod_consu_stress_test")) begin:_plusargs_pcie
              	ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(pcie_prod_consu_stress_test); 
              end:_plusargs_pcie
              else if ($test$plusargs("all_gpra_cmode") || $test$plusargs("pcie_prod_consu_stress_test")) begin:_plusargs_cmode
              	   // all ig memregion are coherent 
                  ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(0);
              end else if ($test$plusargs("all_gpra_ncmode")) begin:_plusargs_ncmode
                 if($test$plusargs("svt_rd_after_wr_to_dii_with_loaded_traffic") && idx == 0)
              	  ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(0);   
                 else
                  ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(1);   // all ig memregion are noncoherent
              end :_plusargs_ncmode
              else begin: _assign_nc_based_on_regions_created
                 //HS 08-19-22: For DMI we cannot just randomly assign NC bit, since non_coh address regions are already created, 
              //which will be used to issue non-coherent transactions RDNOSNP and WRNOSNP. 
              //Only the non-coherent regions created should be marked as NC in GPRA registers
            if (grps_memregion[ig][idx] inside {noncoh_regq}) begin
                    ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(1);  
            end else begin 
                    ncoreConfigInfo::intrlvgrp2noncoh[ig].push_back(0);  
            end
           end: _assign_nc_based_on_regions_created
             end:_dmi
       end:_idx
    end:_ig
    
    // debug print
  //foreach(ncoreConfigInfo::intrlvgrp2noncoh[ig,idx]) begin
    //`uvm_info("ADDR MGR", $sformatf("fn:add_noncoh_info - ig[%0d] region[%0d] noncoh = 0x%0h  !! use only in case AXI4 with proxycache !!", ig, idx, ncoreConfigInfo::intrlvgrp2noncoh[ig][idx]), UVM_LOW)
 //end
endfunction: add_noncoh_info

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : add_security_info
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
//#Constraint.IOAIU.all_gpra_secure
//#Constraint.IOAIU.random_gpra_secure
//#Stimulus.IOAIU.IllegalSecurityAccess.DECERR
function void ncore_memory_map::add_security_info();
   int ig, idx;
        bit [1:0] nsx_val;
        bit temp_nsx;
   for(ig=0; ig<ncoreConfigInfo::intrlvgrp2mem_map.size(); ig=ig+1) begin:_ig
       for(idx=0; idx<ncoreConfigInfo::intrlvgrp2mem_map[ig].size(); idx=idx+1) begin:_idx
           if ($test$plusargs("all_gpra_secure")) begin:_plusargs_secure
               ncoreConfigInfo::intrlvgrp2security[ig].push_back(0);   
            end:_plusargs_secure     
            else if ($test$plusargs("random_gpra_secure")) begin: _plusargs_random 
                if((idx == (ncoreConfigInfo::intrlvgrp2mem_map[ig].size()-1))&&(!temp_nsx))
                std::randomize(nsx_val) with { nsx_val dist {0:=40, 2:=40, 1:=0}; };
                else begin
                std::randomize(nsx_val) with { nsx_val dist {0:=40, 2:=40, 1:=20}; };
                if(!nsx_val)
                temp_nsx = 1;
                end 
                `uvm_info("ADDR MGR", $sformatf("add_security_info random_gpra_secure nsx_val = %0d nsx_val[0] = %0d ",nsx_val,nsx_val[0]), UVM_MEDIUM)
               ncoreConfigInfo::intrlvgrp2security[ig].push_back(nsx_val[0]);
         end:_plusargs_random
         else begin: _plusargs_non_secure
               ncoreConfigInfo::intrlvgrp2security[ig].push_back(1);   
               `uvm_info("ADDR MGR", $sformatf("add_security_info gpra non secure NSX will be 1 "), UVM_MEDIUM)   
            end:_plusargs_non_secure
          end:_idx
    end:_ig
     
   // debug print
     //foreach(ncoreConfigInfo::intrlvgrp2security[ig,idx]) begin
    //   `uvm_info("ADDR MGR", $sformatf("add_security_info - ig[%0d] region[%0d] nsx = 0x%0h", ig, idx, ncoreConfigInfo::intrlvgrp2security[ig][idx]), UVM_LOW)
 //end
endfunction: add_security_info

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : add_memorder_info
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void ncore_memory_map::add_memorder_info();
   ncoreConfigInfo::mem_order_t order, dmi_order_args, dii_order_args;
   bit[1:0] request_order, response_order;
   ncoreConfigInfo::mem_order_t order_q[$];
   int dmi_order_rand;
   int dii_order_rand;
   int ig;
   int idx;
   int dii_idx;
   ncoreConfigInfo::mem_order_t order_arg[6:0];
   int i;
   bit [1:0] rd_wr_incr = 0;
   int rand_policy_q[$];
   int policy_temp_q[$];

    for(int ii=0; ii<4; ii++) begin
        for(int jj=0; jj<4; jj++) begin
            policy_temp_q.push_back(jj);
        end
        policy_temp_q.shuffle();
        rand_policy_q = {rand_policy_q, policy_temp_q};
    end

   for(ig=0; ig<ncoreConfigInfo::intrlvgrp2mem_map.size(); ig=ig+1) begin
       order_q = {};
       for(idx=0; idx<ncoreConfigInfo::intrlvgrp2mem_map[ig].size(); idx=idx+1) begin
       if(ncoreConfigInfo::intrlvgrp_if[ig] == ncoreConfigInfo::DMI) begin
          if($test$plusargs("producer_consumer_m1_order")) begin
             order.readid = 0;
        order.writeid = 0;
             order.policy = 2;
     end
          else if($test$plusargs("producer_consumer_m2_order")) begin
             if(idx == 0) begin
           order.readid = 1;
           order.writeid = 1;
             end else begin
           order.readid = 0;
           order.writeid = 0;
             end
             order.policy = 2;
	  end
      else if($test$plusargs("pcie_prod_consu_stress_test")) begin
             if(idx == 0) begin //idx=0 => coh
	        order.readid = 0;
	        order.writeid = 0;
          order.policy = 3;
             end else begin
	        order.readid = 1;
	        order.writeid = 1;
          order.policy = 2;
             end
      end         
      else begin
             <% if((obj.testBench == "emu")) { %>
             dmi_order_rand = 0;
             <% } else { %>
             dmi_order_rand = $urandom()%2;
             <% } %>
             if(dmi_order_rand == 0) begin
           order.readid = 0;
           order.writeid = 0;
        end else begin
           order.readid = 1;
           order.writeid = 1;
             end
             order.policy = ($urandom()%3)+1;  // 1-3     
     end // if (!$value$plusargs("dmi_mem_order=%h", order))
     if($value$plusargs("dmi_mem_order=%h", dmi_order_args)) begin
	     order = dmi_order_args;
     end
     foreach (order_arg[i]) 
       if ((idx==i) && $value$plusargs({$sformatf("dmi_mem%0d_order",i),"=%h"}, order_arg[i])) order=order_arg[i];
       
     end // if (ncoreConfigInfo::intrlvgrp_if[ig] == ncoreConfigInfo::DMI)
       else begin  // mem order policy for DII
          if($test$plusargs("producer_consumer_m1_order")) begin
        order.readid = 0;
        order.writeid = 0;
             order.policy = 3;
     end
          else if($test$plusargs("producer_consumer_m2_order")) begin
        order.readid = 0;
        order.writeid = 0;
             order.policy = 2;
	  end
     else begin
             <% if((obj.testBench == "emu")) { %>
             dii_order_rand = 0;
             <% } else { %>
           if($test$plusargs("dii_no_relaxed_order")) // CONC-15482: Restrict the configuraion(DII.relaxedOrder==>ReadId=1, WriteId=0) for directed self-checking case.
             dii_order_rand = ($urandom()%2)+1;  // 1-2
           else
             dii_order_rand = ($urandom()%3)+1;  // 1-3
             <% } %>
             if(dii_order_rand == 0) begin
           order.readid = 0;
           order.writeid = 0;
                order.policy = 2'b00;     
             end
        else if(dii_order_rand == 1) begin
           order.readid = 0;
           order.writeid = 0;
                order.policy = 2'b11;     
             end
        else if(dii_order_rand == 2) begin
           order.readid = 0;
           order.writeid = 0;
                order.policy = ($urandom()%2)+1;  // 1-2     
             end
	     else if(dii_order_rand == 3) begin
	        order.readid = 1;
	        order.writeid = 0;
                order.policy = 2'b10;	  
	     end
          end // else
	  if($value$plusargs("dii_mem_order=%h", dii_order_args)) begin
	     order = dii_order_args;
     end
	    foreach (order_arg[i]) 
	            if((dii_idx==i) && $value$plusargs({$sformatf("dii_mem%0d_order",i),"=%h"}, order_arg[i])) order=order_arg[i];
	     dii_idx++;
       end // else: !if(ncoreConfigInfo::intrlvgrp_if[ig] == ncoreConfigInfo::DMI)

          //CONC-11369
          //if wUser=0 && fnQosEnable=0, and there is free-listing meaning ReadId/WriteId=1, there is no way we can precisely match the outgoing CMDreq with an outstanding txn in m_ottq, since txns can go completely out of order. The DV workaroound for this is Do not randomize readId/writeId to 1 when both wUser=0 && fnQosEnable=0
  <% if ( obj.testBench =='io_aiu' ) { %>
          <%if(obj.AiuInfo[obj.Id].fnNativeInterface === "AXI4" || obj.AiuInfo[obj.Id].fnNativeInterface === "AXI5" || obj.AiuInfo[obj.Id].fnNativeInterface === "ACE-LITE" || obj.AiuInfo[obj.Id].fnNativeInterface === "ACELITE-E" || obj.AiuInfo[obj.Id].fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5"){%>

             if(order.readid == 1) begin
               <%if(obj.AiuInfo[obj.Id].nNativeInterfacePorts > 1){%>
                   <% if(obj.AiuInfo[obj.Id].interfaces.axiInt[0].params.wArUser == 0 && obj.AiuInfo[obj.Id].fnEnableQos == 0){%>
                 order.readid = 0; 
                   <% } else { %>
                 order.readid = 1;
                   <% } %>
                <%} else if(obj.AiuInfo[obj.Id].nNativeInterfacePorts ==1) {%>
                   <% if(obj.AiuInfo[obj.Id].interfaces.axiInt.params.wArUser == 0 && obj.AiuInfo[obj.Id].fnEnableQos == 0){%>
                 order.readid = 0; 
                   <% } else { %>
                 order.readid = 1;
                   <% } %>
                <% } %>
             end
             if(order.writeid == 1) begin
               <%if(obj.AiuInfo[obj.Id].nNativeInterfacePorts > 1){%>
                  <% if(obj.AiuInfo[obj.Id].interfaces.axiInt[0].params.wAwUser == 0 && obj.AiuInfo[obj.Id].fnEnableQos == 0){%>
                order.writeid = 0; 
                  <% } else { %>
                order.writeid = 1;
                  <% } %>
                <%} else if(obj.AiuInfo[obj.Id].nNativeInterfacePorts ==1) {%>
                  <% if(obj.AiuInfo[obj.Id].interfaces.axiInt.params.wAwUser == 0 && obj.AiuInfo[obj.Id].fnEnableQos == 0){%>
                order.writeid = 0; 
                  <% } else { %>
                order.writeid = 1;
                  <% } %>
               <% } %>
             end
          <% } %>
 <% } %>
        
        if(ncoreConfigInfo::intrlvgrp_if[ig] == ncoreConfigInfo::DII && ($test$plusargs("conc_17519") || $test$plusargs("conc_17605"))) begin
            order.policy = rand_policy_q.pop_front();
            order.writeid = rd_wr_incr[0];
            order.readid = rd_wr_incr[1];
            rd_wr_incr++;
        end

        if($value$plusargs("request_order=%h", request_order)) begin
	        order.readid = request_order[0];
	        order.writeid = request_order[1];
        end
        if($value$plusargs("response_order=%h", response_order)) begin
	        order.policy = response_order;
        end
        order_q.push_back(order);
    end // foreach (ncoreConfigInfo::intrlvgrp2mem_map[ig][idx])
     
    ncoreConfigInfo::intrlvgrp2mem_order.push_back(order_q);
  end // foreach (ncoreConfigInfo::intrlvgrp2mem_map[ig])

  // debug print
  foreach(ncoreConfigInfo::intrlvgrp2mem_order[ig,idx]) begin
     `uvm_info("ADDR MGR", $sformatf("add_memorder_info - ig[%0d] region[%0d] order = 0x%0h", ig, idx, ncoreConfigInfo::intrlvgrp2mem_order[ig][idx]), UVM_MEDIUM)
  end
 
endfunction: add_memorder_info

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_smallest_memregion_size
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function int ncore_memory_map::pick_smallest_memregion_size(int ig_set_idx);
  bit [63:0] size;
  int count;
  count = 0;
  foreach (grps_memregion[ig_set_idx][idx]) begin
    int memr_idx;
    bit [63:0] sz;

    memr_idx = grps_memregion[ig_set_idx][idx];
    sz = ncoreConfigInfo::memregion_boundaries[memr_idx].end_addr -
         ncoreConfigInfo::memregion_boundaries[memr_idx].start_addr;

    if ((size == 0) || (size > sz))
      size = sz;
  end
  while (size) begin
    count++;
    size = size >> 1;
  end
  return count;
endfunction: pick_smallest_memregion_size

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : low_ordr_region
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function int ncore_memory_map::low_ordr_region(int val);
  bit [63:0] addr;
  int ret = 0;

  addr = ncoreConfigInfo::memregion_boundaries[grps_memregion[val][0]].start_addr;
  foreach (grps_memregion[val,i]) begin
    int n = grps_memregion[val][i];

    if (ncoreConfigInfo::memregion_boundaries[n].start_addr < addr) begin
      addr = ncoreConfigInfo::memregion_boundaries[n].start_addr;
      ret = n;
    end
  end
  return ret;
endfunction: low_ordr_region


////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : hgh_ordr_region
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function int ncore_memory_map::hgh_ordr_region(int val);
  bit [63:0] addr;
  int ret = 0;

  addr = ncoreConfigInfo::memregion_boundaries[grps_memregion[val][0]].start_addr;
  foreach (grps_memregion[val,i]) begin
    int n = grps_memregion[val][i];

    if (ncoreConfigInfo::memregion_boundaries[n].start_addr > addr) begin
      addr = ncoreConfigInfo::memregion_boundaries[n].start_addr;
      ret = n;
    end
  end
  return ret;
endfunction: hgh_ordr_region

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : count_ones
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function int ncore_memory_map::count_ones(bit [63:0] val);
  int ret = 0;

  while(val != 0) begin
    if (val[0])
      ret++;
    val = val >> 1;
  end
  return ret;
endfunction: count_ones

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void ncore_memory_map::pick_regions();
  int noncoh_region_pct = 50;
  int dce_fix_index     = $test$plusargs("dce_fix_index");
  $value$plusargs("noncoh_region_pct=%d", noncoh_region_pct);
  //Store regions per memory type
  if ((dce_fix_index || (noncoh_region_pct == 0))
     && dii_grps.size() == 0) begin
      `uvm_info("pick_regions",$sformatf("Skipping call to pick_noncoh_regions. Because Either dce_fix_index or noncoh_region_pct=0 is used and there are no DII present in the config."), UVM_NONE)
   end else begin
      noncoh_regq = pick_noncoh_regions();
   end
  iocoh_regq  = pick_iocoh_regions();
  coh_regq    = pick_coh_regions();
  nrs_regq    = pick_nrs_regions();
  boot_regq   = pick_boot_regions();
endfunction: pick_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_regions_assoc2targetid
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::pick_regions_assoc2targetid(
    int agentid);
  int lid, cid;
  ncoreConfigInfo::ncore_unit_type_t utype;
  int ig_id;

  ncoreConfigInfo::get_logical_uinfo(agentid, lid, cid, utype);
  if (utype == ncoreConfigInfo::DMI)
    ig_id = lid;    
  else if (utype == ncoreConfigInfo::DII)
    ig_id = ncoreConfigInfo::logical2dmi_map.size() + lid;
  else
    `uvm_fatal("ADDR MGR", "Unexpected agent-id passed")

  return grps_memregion[ig_id];
endfunction: pick_regions_assoc2targetid

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_noncoh_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::pick_noncoh_regions();
  int q[$];
  int igv_cnt = 0;
  int grp;
  int noncoh_region_pct = 50;
   
//  if (ncoreConfigInfo::NGPRA == nintrlv_grps.size())
//begin
//$display("NGPRA: %d, ninitrl %d", ncoreConfigInfo::NGPRA, nintrlv_grps.size());
//   return q;
//end

  if($test$plusargs("noncoh_region_pct")) begin
     $value$plusargs("noncoh_region_pct=%d", noncoh_region_pct);
  end

  noncoh_reg_maps_to_dii = 0;
     
  if(noncoh_region_pct > 0) begin
    foreach (dmi_grps[idx]) begin
      if(!$test$plusargs("dce_fix_index")) begin
          if(!$test$plusargs("one_memregion_by_aiu")) begin
          // for DMI interleave group with multiple mapped memory regions, pick 1 region in the group as non-coherernt
          if (grps_memregion[igv_cnt].size() > 1 || ($test$plusargs("all_gpra_ncmode") && grps_memregion[igv_cnt].size() >0)) begin
            grp = $urandom_range(0, grps_memregion[igv_cnt].size()-1);
            `uvm_info("pick_noncoh_regions",$sformatf("Pushing DMI memrgion[%0d][%0d]=%0d", igv_cnt, grp, grps_memregion[igv_cnt][grp]),UVM_NONE)           
            q.push_back(grps_memregion[igv_cnt][grp]);
        end
      end else begin // else one_memregion_by_aiu
          // for DMI interleave group with multiple mapped memory regions, pick 1 region FOR EACH NCAIU in the group as non-coherernt
          if (grps_memregion[igv_cnt].size() > 1 || ($test$plusargs("all_gpra_ncmode") && grps_memregion[igv_cnt].size() >0)) begin
        for (grp=1; grp< <%=obj.nAIUs%> ; grp++) begin // start at 1 because 0= coh
            `uvm_info("pick_noncoh_regions",$sformatf("Pushing DMI memrgion[%0d][%0d]=%0d", igv_cnt, grp, grps_memregion[igv_cnt][grp]),UVM_NONE)           
            q.push_back(grps_memregion[igv_cnt][grp]);
            end // end for
            end // end size() >1  
      end// end newperf_test_scb
      end // end !dce_fix_index
      ++igv_cnt;
    end // end foreach

    // if all DMI interleave groups only have 1 assigned memory region, pick 1 DMI interleave group as non-coherent
    if (q.size() == 0) begin
      if(!$test$plusargs("dce_fix_index")) begin
          if(dmi_grps.size() > 1) begin
            grp = $urandom_range(0, dmi_grps.size()-1);
            `uvm_info("pick_noncoh_regions",$sformatf("Pushing DMI memrgion[%0d][%0d]=%0d", grp, 0, grps_memregion[grp][0]),UVM_NONE)           
            q.push_back(grps_memregion[grp][0]);
          end
      end
    end
  end

  // if no DMI interleave group is assigned as non-coherent, pick DII group
  if (q.size() == 0) begin
    foreach (dii_grps[idx]) begin
      igv_cnt = igv_cnt + idx;
      if (grps_memregion[igv_cnt].size() > 0) begin
        grp = $urandom_range(0, grps_memregion[igv_cnt].size()-1);
        `uvm_info("pick_noncoh_regions",$sformatf("Pushing DII memrgion[%0d][%0d]=%0d", igv_cnt, grp, grps_memregion[igv_cnt][grp]),UVM_NONE)
        q.push_back(grps_memregion[igv_cnt][grp]);
        noncoh_reg_maps_to_dii = 1;
      end
    end
  end

  `ASSERT(q.size() != 0,
      "Pick nMemRegions so that there is atleast one non-coherent region"
  );

  return q;
endfunction: pick_noncoh_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_iocoh_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::pick_iocoh_regions();
  int q[$];
  if (ncoreConfigInfo::NUM_DIIS == 0)
    return q;

  foreach (nintrlv_grps[idx]) begin
    if (nintrlv_type[idx] == ncoreConfigInfo::DII) begin
      foreach (grps_memregion[idx][cidx]) 
        q.push_back(grps_memregion[idx][cidx]);
    end
  end
  return q;
endfunction: pick_iocoh_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_coh_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::pick_coh_regions();
  int q[$];

  foreach (dmi_grps[idx]) begin
     foreach (grps_memregion[idx][cidx]) begin
       int c[$];
       c = noncoh_regq.find(x) with (x == grps_memregion[idx][cidx]);
       if (c.size() == 0)
         q.push_back(grps_memregion[idx][cidx]);
     end
  end
 return q;
endfunction: pick_coh_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_nrs_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::pick_nrs_regions();
   int       q[$];
   q.push_back(ncoreConfigInfo::NRS_REGION_BASE);
   return q;
endfunction : pick_nrs_regions
   
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_boot_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::pick_boot_regions();
   int       q[$];
   q.push_back(ncoreConfigInfo::BOOT_REGION_BASE);
   return q;
endfunction : pick_boot_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_rand_memregion
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function int ncore_memory_map::get_rand_memregion(
  ncoreConfigInfo::addr_format_t mem_type, int agentid = -1);
  int try_count;
  int try_count_total = 100_000;// Because some configuration as MEYE7 has a lot of memory region but only few target connected
  int mem_id;
  bit mem_id_found;
  int mem_reg_idx[$];

  try_count = try_count_total; 
 <% if ((obj.testBench == "fsys" || (obj.testBench === "cust_tb") || obj.testBench == "emu" || obj.testBench =='io_aiu' || obj.testBench =='chi_aiu') && obj.initiatorGroups.length >= 1) { %>
  do begin
  <%}%>
  <% if ( obj.testBench =='dce' && obj.initiatorGroups.length > 1) { %>
  do begin
  <%}%>

  if (mem_type == ncoreConfigInfo::COH) begin
    `ASSERT(coh_regq.size());
    if($test$plusargs("use_single_memregion")) begin
       mem_id = coh_regq[0];
    end else begin
       mem_id = coh_regq[$urandom_range(0, coh_regq.size()-1)];
    end
  end

  if (mem_type == ncoreConfigInfo::IOCOH) begin
    `ASSERT(iocoh_regq.size());    
    if($test$plusargs("use_single_memregion")) begin
       mem_id = iocoh_regq[0];
    end else begin
       mem_id = iocoh_regq[$urandom_range(0, iocoh_regq.size()-1)];
    end
  end

  if (mem_type == ncoreConfigInfo::BOOT) begin
    `ASSERT(boot_regq.size());
     mem_id = boot_regq[0];
     mem_id_found = 1;
  end
   
  if (mem_type == ncoreConfigInfo::NRS) begin
    `ASSERT(nrs_regq.size());
     mem_id = nrs_regq[0];
     mem_id_found = 1;
  end
   
  if (mem_type == ncoreConfigInfo::NONCOH) begin
    `ASSERT(noncoh_regq.size());
    if($test$plusargs("use_single_memregion")) begin
      mem_id = noncoh_regq[0];
    end else begin
      mem_id = noncoh_regq[$urandom_range(0, noncoh_regq.size()-1)];
    end
  end

<% if ((obj.testBench == "fsys" || (obj.testBench === "cust_tb") || obj.testBench == "emu" || obj.testBench =='io_aiu' || obj.testBench =='chi_aiu') && obj.initiatorGroups.length >= 1) { %>

  if($test$plusargs("use_single_memregion")) begin
    if (mem_type == ncoreConfigInfo::IOCOH) begin // Need to use connected DII region 
      if(agentid != -1) begin
        mem_reg_idx = ncoreConfigInfo::memregions_info.find_index(mid) with ( 
          mid.hut == ncoreConfigInfo::DII &&
          ncoreConfigInfo::get_dii_funitid(mid.hui) inside {ncoreConfigInfo::aiu_connected_dii_ids[agentid].ConnectedfUnitIds} );
        mem_id = mem_reg_idx[0];
        mem_id_found = 1;
      end else begin  
        mem_id = iocoh_regq[$urandom_range(0, iocoh_regq.size()-1)]; //No possibility to know connected Region as agentid==-1
      end
    //end else if (mem_type == ncoreConfigInfo::NONCOH) begin 
    //end else if (mem_type == ncoreConfigInfo::COH) begin  
    end
  end

  mem_reg_idx = ncoreConfigInfo::memregions_info.find_index(mid) with (mid.start_addr == lbound(mem_id));
  
  if( ! mem_id_found &&  agentid != -1) begin
    if(ncoreConfigInfo::memregions_info[mem_reg_idx[0]].hut == ncoreConfigInfo::DMI) begin
      foreach(ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]) begin
        mem_id_found = 
          ncoreConfigInfo::dmi_ids[ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]] inside
            {ncoreConfigInfo::aiu_dce_connected_dce_dmi_dii_ids[agentid].ConnectedfUnitIds};
        if(mem_id_found) break;
      end
    end else begin
      mem_id_found = ncoreConfigInfo::dii_ids[ncoreConfigInfo::memregions_info[mem_reg_idx[0]].hui] inside {ncoreConfigInfo::aiu_dce_connected_dce_dmi_dii_ids[agentid].ConnectedfUnitIds};
    end
  end

  try_count--;

end while(try_count!=0 && agentid != -1 && !test_connectivity_test && !mem_id_found );

if(!try_count) begin
  $stacktrace;
  `uvm_error("Connectivity Interleaving ADDR MGR",$sformatf("Not succeed to generate connected memory index region for ID %0D mem_type %0p, Hitting possible 0-time infinite loop here", agentid, mem_type))
end 
<%}
 if(obj.testBench == "dce" && obj.initiatorGroups.length > 1){%>
  mem_reg_idx = ncoreConfigInfo::memregions_info.find_index(mid) with (mid.start_addr == lbound(mem_id));
  
  if( ! mem_id_found &&  agentid != -1) begin
    if(ncoreConfigInfo::memregions_info[mem_reg_idx[0]].hut == ncoreConfigInfo::DMI) begin
      foreach(ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]) begin
        mem_id_found = ncoreConfigInfo::dmi_ids[ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]] inside {ncoreConfigInfo::dce_connected_dmi_ids[0].ConnectedfUnitIds};
        if(mem_id_found) break;
      end
    end
  end

  try_count--;

end while(try_count!=0 && agentid != -1 && !mem_id_found );

if(!try_count) begin
  $stacktrace;
  `uvm_error("Connectivity Interleaving ADDR MGR",$sformatf("Not succeed to generate connected memory index region, Hitting possible 0-time infinite loop here"))
end 
<%}%>

return mem_id;
endfunction: get_rand_memregion

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : lbound
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit[63:0] ncore_memory_map::lbound(int mid);
  `ASSERT(mid < ncoreConfigInfo::NGPRA);
  return ncoreConfigInfo::memregion_boundaries[mid].start_addr;
endfunction: lbound

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : ubound
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit[63:0] ncore_memory_map::ubound(int mid);
  `ASSERT(mid < ncoreConfigInfo::NGPRA);
  return ncoreConfigInfo::memregion_boundaries[mid].end_addr;
endfunction: ubound

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_port_sel_bits
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::sel_bits_t ncore_memory_map::get_port_sel_bits(
  int logical_id,
  ncoreConfigInfo::ncore_unit_type_t utype);
  ncoreConfigInfo::sel_bits_t m_sel;

  `ASSERT(utype == ncoreConfigInfo::DMI);
  m_sel.pri_bits = new[ncoreConfigInfo::dmi_port_sel[logical_id].num_pri_bits];
  m_sel.sec_bits = new[ncoreConfigInfo::dmi_port_sel[logical_id].num_pri_bits];

  foreach (ncoreConfigInfo::dmi_port_sel[logical_id].pri_bits[i])
    m_sel.pri_bits[i] = ncoreConfigInfo::dmi_port_sel[logical_id].pri_bits[i];

  foreach (ncoreConfigInfo::dmi_port_sel[logical_id].sec_bits[i]) begin
    if (ncoreConfigInfo::dmi_port_sel[logical_id].sec_bits[i].size() > 0) begin

      m_sel.sec_bits[i] = new[
        ncoreConfigInfo::dmi_port_sel[logical_id].sec_bits[i].size()];

      foreach (ncoreConfigInfo::dmi_port_sel[logical_id].sec_bits[i][j])
        m_sel.sec_bits[i][j] = 
        ncoreConfigInfo::dmi_port_sel[logical_id].sec_bits[i][j];
    end
  end

  return m_sel;
endfunction: get_port_sel_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_coh_mem_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::get_coh_mem_regions();
  return coh_regq;
endfunction: get_coh_mem_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_iocoh_mem_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::get_iocoh_mem_regions();
  return iocoh_regq;
endfunction: get_iocoh_mem_regions
  
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_noncoh_mem_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::get_noncoh_mem_regions();
  return noncoh_regq;
endfunction: get_noncoh_mem_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_nrs_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::get_nrs_regions();
  return nrs_regq;
endfunction: get_nrs_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_boot_regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::intq ncore_memory_map::get_boot_regions();
  return boot_regq;
endfunction: get_boot_regions

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : fill_memregions_info
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void ncore_memory_map::fill_memregions_info();
  ncoreConfigInfo::sys_addr_csr_t csrq[$];
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr;
  ncoreConfigInfo::memregion_info_t mem_info;
  int nregion = 0;
  int dmi_start_nunitid = 0;
  int memregions_cnt = 1;
   
  foreach (nintrlv_grps[i]) begin
     csrq = ncoreConfigInfo::get_memregions_assoc_ig(i);
     foreach (csrq[j]) begin
        if($test$plusargs("conc_17519") || $test$plusargs("conc_17605")) begin
            if (memregions_cnt == csrq[j].size) begin
                csrq[j].unit = 1;
                csrq[j].nc = 0;
            end else begin
                csrq[j].unit = 0;
            end
            memregions_cnt++;
        end
   low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
   upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;

   mem_info.start_addr = low_addr;
   mem_info.end_addr = upp_addr;
        //mem_info.size = csrq[j].size;
        mem_info.size = $clog2((upp_addr+1)-low_addr) - 12;
   mem_info.hut = csrq[j].unit;
  mem_info.hui = csrq[j].mig_nunitid;
  mem_info.UnitIds.delete();
  for(int idx=0; idx < nintrlv_grps[i]; idx++) begin
    if (csrq[j].unit == ncoreConfigInfo::DMI)
      mem_info.UnitIds.push_back(dmi_start_nunitid + idx);
    else 
      mem_info.UnitIds.push_back(csrq[j].mig_nunitid + idx);
 end
   //ncoreConfigInfo::memregions_info.push_back(mem_info);
   ncoreConfigInfo::memregions_info[nregion] = mem_info;
        `uvm_info("ADDR MGR", $sformatf("fill_memregions_info - memregion[%0d] = %p", nregion, ncoreConfigInfo::memregions_info[nregion]), UVM_MEDIUM)
        nregion++;
     end // foreach (csrq[j])
     if (nintrlv_type[i] == ncoreConfigInfo::DMI) begin
        dmi_start_nunitid = dmi_start_nunitid + nintrlv_grps[i];
     end
  end // foreach (nintrlv_grps[i])

endfunction: fill_memregions_info
   
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : convert2string
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function string ncore_memory_map::convert2string();
  string s;
  ncoreConfigInfo::sys_addr_csr_t csrq[$];
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr;
  int dmi_start_nunitid = 0;

  $sformat(s, "InterleaveGroups: { ");
  foreach(nintrlv_grps[i])
    $sformat(s, "%s %0d", s, nintrlv_grps[i]);
  $sformat(s, "%s }", s);

  $sformat(s, "%s\nInterleaveGroupUnits: { ", s);
  foreach(nintrlv_type[i])
    $sformat(s, "%s %s", s, nintrlv_type[i].name);
  $sformat(s, "%s }", s);

  $sformat(s, "%s\nnMemoryRegions: %0d", s, ncoreConfigInfo::NGPRA);
  $sformat(s, "%s\nmappedMemoryRegionsToInterleaveGroup { ", s);
  foreach (grps_memregion[i]) begin
    $sformat(s, "%s { ", s);
    foreach (grps_memregion[i][j])
      $sformat(s, "%s %0d ", s, grps_memregion[i][j]);
    $sformat(s, "%s } ", s);
  end
  $sformat(s, "%s }", s);
  $sformat(s, "%s\nmappedMemoryRegionsOrderPolicy { ", s);
  foreach (ncoreConfigInfo::intrlvgrp2mem_order[i]) begin
    $sformat(s, "%s { ", s);
    foreach (ncoreConfigInfo::intrlvgrp2mem_order[i][j])
      $sformat(s, "%s 0x%0h ", s, ncoreConfigInfo::intrlvgrp2mem_order[i][j]);
    $sformat(s, "%s } ", s);
  end
  $sformat(s, "%s }", s);

  $sformat(s, "%s\nMemoryRegions: ", s);
  if(ncoreConfigInfo::program_nrs_base) begin
    $sformat(s, "%s\n%s ", s,old_nrs);
    $sformat(s, "%s\n%s ", s,new_nrs);
  end
  foreach (ncoreConfigInfo::memregion_boundaries[i])
    $sformat(s, "%s { 0x%0h 0x%0h } ", s,
      ncoreConfigInfo::memregion_boundaries[i].start_addr,
      ncoreConfigInfo::memregion_boundaries[i].end_addr);

   $sformat(s, "%s\n", s);
   $sformat(s, "%s-------------------------------------------------------------------------------------------------------------------------------------------------------\n", s);
   $sformat(s, "%s|         Addr                        |  Region      | nUnitID         |    Interleaving Bits |   NC   |  NSX   | ReadId | WriteId |    Order Policy    |\n", s);
   $sformat(s, "%s-------------------------------------------------------------------------------------------------------------------------------------------------------\n", s);
   $sformat(s, "%s| { 0x%12h 0x%12h }   |  BOOT        |", s, ncoreConfigInfo::BOOT_REGION_BASE, ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE-1);
   <% if (obj.AiuInfo[1].BootInfo.regionHut == 0) { %>
   $sformat(s, "%s %s %0d", s, "DMI", <%=obj.DmiInfo[0].InterleaveInfo.dmiIGSV[0].IGV[obj.AiuInfo[0].BootInfo.regionHui].DMIIDV[0]%>);
   <% if (obj.DmiInfo[0].InterleaveInfo.dmiIGSV[0].IGV[obj.AiuInfo[0].BootInfo.regionHui].DMIIDV.length > 1) { %>
      <% for(var unit_idx = 1; unit_idx < obj.DmiInfo[0].InterleaveInfo.dmiIGSV[0].IGV[obj.AiuInfo[0].BootInfo.regionHui].DMIIDV.length; unit_idx++) { %>
      $sformat(s, "%s %0d", s, <%=obj.DmiInfo[0].InterleaveInfo.dmiIGSV[0].IGV[obj.AiuInfo[0].BootInfo.regionHui].DMIIDV[unit_idx]%>);
      <% } %>
   $sformat(s, "%s        |                      |        |        |        |         |                    |\n", s);     
   <% } else { %>
   $sformat(s, "%s                      |        |        |        |         |                    |\n", s);     
   <% } %>
   <% } else { %>
   $sformat(s, "%s %s %0d           |", s, "DII", <%=obj.AiuInfo[0].BootInfo.regionHui%>);
   $sformat(s, "%s                      |        |        |        |         |                    |\n", s);     
   <% } %>
   $sformat(s, "%s| { 0x%12h 0x%12h }   |  CSR         |", s, (ncoreConfigInfo::program_nrs_base? ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[0] :ncoreConfigInfo::NRS_REGION_BASE), (ncoreConfigInfo::program_nrs_base?ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[0] :ncoreConfigInfo::NRS_REGION_BASE) + ncoreConfigInfo::NRS_REGION_SIZE-1);
   $sformat(s, "%s DII SYS         |", s);
   $sformat(s, "%s                      |        |        |        |         |                    |\n", s);     
  foreach (nintrlv_grps[i]) begin
     csrq = ncoreConfigInfo::get_memregions_assoc_ig(i);
     $sformat(s, "%s|                                     |              |                 |                      |        |        |        |         |                    |\n", s);
     foreach (csrq[j]) begin
   low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
   upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
        $sformat(s, "%s| { 0x%12h 0x%12h } |  GPA         |", s, low_addr, upp_addr);
   if(csrq[j].unit == ncoreConfigInfo::DMI) begin
           $sformat(s, "%s %s", s, csrq[j].unit.name());
           for(int unit=0; unit<nintrlv_grps[i]; unit=unit+1) begin
              $sformat(s, "%s %0d", s, dmi_start_nunitid+unit);
      end
      if(nintrlv_grps[i] == 2) begin
              $sformat(s, "%s         |", s);
      end 
           else if(nintrlv_grps[i] == 3) begin
              $sformat(s, "%s       |", s);
           end
           else if(nintrlv_grps[i] == 4) begin
              $sformat(s, "%s     |", s);
           end
      else begin
              $sformat(s, "%s           |", s);
      end 
   end // if (csrq[j].unit == ncoreConfigInfo::DMI)
   else begin
           $sformat(s, "%s %s %0d           |", s, csrq[j].unit.name(), csrq[j].mig_nunitid);
        end // else: !if(csrq[j].unit == ncoreConfigInfo::DMI)
        if(nintrlv_grps[i] > 1) begin
           foreach(ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[nintrlv_grps[i]]][nintrlv_grps[i]].pri_bits[b]) begin
              $sformat(s, "%s %0d", s, ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[nintrlv_grps[i]]][nintrlv_grps[i]].pri_bits[b]);     
           end
      if(nintrlv_grps[i] == 2) begin
              $sformat(s, "%s                    |", s);     
           end
      else begin
              $sformat(s, "%s                  |", s);     
           end                    
   end // if (nintrlv_grps[i] > 1)
   else begin
           $sformat(s, "%s                      |", s);     
        end // else: !if(nintrlv_grps[i] > 1)
        $sformat(s, "%s   %0d    |", s, csrq[j].nc);
        $sformat(s, "%s   %0b    |", s, csrq[j].nsx);
        $sformat(s, "%s   %0d    |", s, csrq[j].order.readid);
        $sformat(s, "%s   %0d     |", s, csrq[j].order.writeid);
        if(csrq[j].order.policy == 2'b00) begin
            $sformat(s, "%s  %0d (%s)   |\n", s, csrq[j].order.policy, "  Reserved  ");
        end else if(csrq[j].order.policy == 2'b01) begin
            $sformat(s, "%s  %0d (%s)   |\n", s, csrq[j].order.policy, " WriteOrder ");
        end else if(csrq[j].order.policy == 2'b10) begin
            $sformat(s, "%s  %0d (%s)  |\n", s, csrq[j].order.policy, "RelaxedOrder ");
        end else if(csrq[j].order.policy == 2'b11) begin
            $sformat(s, "%s  %0d (%s)  |\n", s, csrq[j].order.policy, "EndPointOrder ");
        end
     end // foreach (csrq[j])
     if(nintrlv_type[i] == ncoreConfigInfo::DMI) begin
        dmi_start_nunitid = dmi_start_nunitid + nintrlv_grps[i];
     end
  end // foreach (nintrlv_grps[i])
  $sformat(s, "%s-------------------------------------------------------------------------------------------------------------------------------------------------------\n", s);
   
  return s;
endfunction: convert2string

