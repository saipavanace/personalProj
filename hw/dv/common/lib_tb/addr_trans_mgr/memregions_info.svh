
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Class : memregions_info
// Description : Helper class for address manager to randomly 
//               generate start, end boundaries of various memory regions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
//import "DPI-C" function string getenv(input string env_name);
class memregions_info;
  
  typedef int intq[$];
  string ext_mem_path;
  
  //Below varaiables are randomized
  rand bit[63:0] st_addr[$];  
  rand bit[63:0] size[$];
  
  //Expected to be set by user
  int nmemregions;
  int memrg2ig_map[$];
  
  //Internal variables
  bit[63:0] b1q[$];
  bit[63:0] b2q[$];
  bit[63:0] b3q[$];
  bit[63:0] b4q[$];
  bit[63:0] b8q[$];
  bit[63:0] b16q[$];
  bit       sep_c_nc;   // seperate address of coh and non-coh in the same region
  bit       mem_regions_overlap;
  bit       fixed_memregions;
  int       fixed_memregions_size;
//#Stimulus.IOAIU.MultipleAddrhit.DECERR
  constraint c2 {
    foreach (st_addr[i]) {
      if (mem_regions_overlap==0) {
        (memrg2ig_map[i] == 1) -> size[i] inside {b1q};
        (memrg2ig_map[i] == 2) -> size[i] inside {b2q};
        (memrg2ig_map[i] == 3) -> size[i] inside {b3q};
        (memrg2ig_map[i] == 4) -> size[i] inside {b4q};
        (memrg2ig_map[i] == 8) -> size[i] inside {b8q};
        (memrg2ig_map[i] == 16) -> size[i] inside {b16q};
      } else if (mem_regions_overlap==1) {
        size[i] == b1q[0];
      }
      st_addr[i] % size[i] == 0;
      st_addr[i][11:0]     == 0;  //4K aligned base addresses
      //st_addr[i] inside {[0: (1 << ncoreConfigInfo::ADDR_WIDTH) - 1]};
      if(fixed_memregions == 1) {
      <% if(obj.testBench == "emu") { %>
        st_addr[i] == (i+1)<<16;
    <% } else {%>
        st_addr[i] == (i+1)<<32;
      <% } %>
      }
      st_addr[i] inside {[0: (1 << ncoreConfigInfo::MIN_ADDR_WIDTH) - 1]};
      !(st_addr[i] inside {[ncoreConfigInfo::BOOT_REGION_BASE:(ncoreConfigInfo::BOOT_REGION_BASE+ncoreConfigInfo::BOOT_REGION_SIZE-1)]});
      !(st_addr[i] inside {[ncoreConfigInfo::NRS_REGION_BASE:(ncoreConfigInfo::NRS_REGION_BASE+ncoreConfigInfo::NRS_REGION_SIZE-1)]});
      !((st_addr[i] < ncoreConfigInfo::BOOT_REGION_BASE) && ((st_addr[i] + size[i]) > ncoreConfigInfo::BOOT_REGION_BASE));
      !((st_addr[i] < ncoreConfigInfo::NRS_REGION_BASE) && ((st_addr[i] + size[i]) > ncoreConfigInfo::NRS_REGION_BASE));

      foreach (st_addr[j]) {
         ((mem_regions_overlap==0)&&(i!=j)) -> !(st_addr[i] inside {[st_addr[j] : (st_addr[j] + size[j] - 1)]});
         ((mem_regions_overlap==1)&&(i!=j)) -> (st_addr[i] inside {[st_addr[j] : (st_addr[j] + size[j] - 1)]});
      }
    }
    st_addr.size() == nmemregions;
    size.size() == nmemregions;
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Function : print
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  function void print();
    string s;
    integer outfile;
    string line,addr,regi;
    int i;
    bit[63:0] s_addr,end_addr,low_addr_que[$],upp_addr_que[$];

    // FIXME: Below if condition should be moved out of this print function
    if($test$plusargs("override_memregions")) begin //use this plusarg only when need to reconfigure address map and make sure memregions.txt file exists
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
      
        outfile=$fopen(ext_mem_path,"r"); //external file path containing data required for reconfiguring address map
        void'($fscanf(outfile,"%s",line));
        for(int j=0;j<nmemregions;j++)begin
            void'($fscanf(outfile," { 0x%h  0x%h } ",s_addr,end_addr));
            low_addr_que.push_back(s_addr);
            upp_addr_que.push_back(end_addr);
        end
        $sformat(s, "%s Memregions: ", s);   // here configuring MemoryRegions
        foreach (st_addr[i]) begin
            size[i] = (upp_addr_que[i]-low_addr_que[i]);
            st_addr[i] = low_addr_que[i];
            $sformat(s, "%s {0x%0h : 0x%0h}", s, st_addr[i], (st_addr[i] + size[i]));
        end
    end else begin
    $sformat(s, "%s Memregions: ", s);
        foreach (st_addr[i]) begin
        $sformat(s, "%s {0x%0h : 0x%0h}", s, st_addr[i], (st_addr[i] + size[i]));
        end
    end
  
    $display(s);
  endfunction: print

  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Function : post_randomize
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  function void post_randomize();
    foreach (size[i]) begin
      `ASSERT(size[i] % memrg2ig_map[i] == 0);
      `ASSERT(ispow2(size[i] / memrg2ig_map[i]));
      `ASSERT(st_addr[i] + size[i] <= (1 << ncoreConfigInfo::MIN_ADDR_WIDTH));
      `ASSERT(st_addr[i] + size[i] >= st_addr[i] + 4096); //Min size is 4KB
    end
  endfunction: post_randomize
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Function : ispow2
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  function bit ispow2(bit [63:0] val);
    int count = 0;
    while (val) begin
      if (val[0])
        count++;
      if (count > 1)
        return 0;
      val = val >> 1;
    end
    return 1;
  endfunction: ispow2
    
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Function : new
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  function new();

    <%if(obj.testBench == "chi_aiu") { %>
         const int MAX = ($test$plusargs("pick_boundary_addr") && $test$plusargs("hw_cfg_41_cov")) ? ncoreConfigInfo::MIN_ADDR_WIDTH : (ncoreConfigInfo::MIN_ADDR_WIDTH > 43 ? 44 : ncoreConfigInfo::MIN_ADDR_WIDTH); 
    <% } else { %>
         const int MAX = ncoreConfigInfo::MIN_ADDR_WIDTH > 43 ?
                     44 : ncoreConfigInfo::MIN_ADDR_WIDTH;
    <% } %>

    bit merg_c_nc;
    int min_size;
    int gpra_min_size;
    int gpra_max_size;
 


    if ( ! $value$plusargs("merg_c_nc=%d", merg_c_nc) ) begin
       merg_c_nc = 0;
    end

    sep_c_nc = 1 - merg_c_nc;

    if($test$plusargs("mem_regions_overlap")) begin    
       mem_regions_overlap = 1'b1;
    end else begin
       mem_regions_overlap = 1'b0;
    end

    if($test$plusargs("fixed_memregions")) begin    
       fixed_memregions = 1'b1;
    end else begin
       fixed_memregions = 1'b0;
    end

    if(!$value$plusargs("fixed_memregions_size=%d", fixed_memregions_size)) begin    
       fixed_memregions_size = 0;
    end

    if ( ! $value$plusargs("memregion_min_size=%d", min_size) ) begin
       if ($test$plusargs("use_large_memregion") ) begin
          min_size = 24;  // minimum 16MB
       end
       else begin
        <%if(obj.testBench == "chi_aiu") { %>
           if($test$plusargs("pick_boundary_addr") && ($test$plusargs("memregion_rand_size") && ($value$plusargs("gpra_min_size=%d", gpra_min_size)) && ($value$plusargs("gpra_max_size=%d", gpra_max_size)))) begin
              min_size = $urandom_range(gpra_max_size, gpra_min_size);  // minimum 16MB
              $display("comig_here_in_addr_mgr min : %0h max : %0h", gpra_max_size, gpra_min_size);
           end else begin
              min_size = ((ncoreConfigInfo::MIN < 12) || (ncoreConfigInfo::MIN  > 24)) ?
                     12 : ncoreConfigInfo::MIN;
           end
        <% } else { %>
          min_size = ((ncoreConfigInfo::MIN < 12) || (ncoreConfigInfo::MIN  > 24)) ?
                     12 : ncoreConfigInfo::MIN;
        <% } %>
       end
    end

    //if sep_c_nc is set, increase region size to minimum 16KB.   
    //Creating multiple of 4096 bytes if nDmis == 1 per IGV
    if(fixed_memregions_size > 0) begin
       b1q.push_back(64'h1 << (fixed_memregions_size+2*sep_c_nc));
       `uvm_info("ADDR MGR DBG", $sformatf("fixed_memregions_size=%0d, b1q push size %0d", fixed_memregions_size, 64'h1 << (fixed_memregions_size+2*sep_c_nc)), UVM_NONE)
    end else begin
    for (int i = min_size+2*sep_c_nc; i < MAX; ++i)
       b1q.push_back((64'h1 << i));
    end

    //Creating multiple of 2 * 4096 bytes if nDmis == 2 per IGV
    if(fixed_memregions_size > 0) begin
       b2q.push_back(64'h1 << (fixed_memregions_size+1+2*sep_c_nc));
    end else begin
    for (int i = min_size+1+2*sep_c_nc; i < MAX; ++i)
      b2q.push_back((64'h1 << i));
    end
    
    //Creating multiple of 4 * 4096 bytes if nDmis == 4 per IGV
    if(fixed_memregions_size > 0) begin
       b4q.push_back(64'h1 << (fixed_memregions_size+2+2*sep_c_nc));
    end else begin
    for (int i = min_size+2+2*sep_c_nc; i < MAX; ++i)
      b4q.push_back((64'h1 << i));
    end

    //Creating multiple of 3 * 4096 bytes if nDmis == 3 per IGV
    for (int i = min_size+2*sep_c_nc; i < MAX; ++i) begin
      bit [63:0] val = 3 * (1 << i);
      if (val < (1 << ncoreConfigInfo::MIN_ADDR_WIDTH))
        b3q.push_back(val);
    end
    
    //Creating multiple of 8 * 4096 bytes if nDmis == 8 per IGV
    if(fixed_memregions_size > 0) begin
       b8q.push_back(64'h1 << (fixed_memregions_size+3+2*sep_c_nc));
    end else begin
    for (int i = min_size+3+2*sep_c_nc; i < MAX; ++i)
      b8q.push_back((64'h1 << i));
    end

    //Creating multiple of 16 * 4096 bytes if nDmis == 16 per IGV
    if(fixed_memregions_size > 0) begin
       b16q.push_back(64'h1 << (fixed_memregions_size+4+2*sep_c_nc));
    end else begin
    for (int i = min_size+4+2*sep_c_nc; i < MAX; ++i)
      b16q.push_back((64'h1 << i));
    end

  endfunction: new

endclass: memregions_info

