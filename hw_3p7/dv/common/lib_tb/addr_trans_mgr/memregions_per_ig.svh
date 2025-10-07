////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Class : memregions_per_ig
// Description : Helper class for address manager to assign unique memory regions to each IG
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
//import "DPI-C" function string getenv(input string env_name);

class memregions_per_ig;
  int min_memregions, max_memregions;
  int ig_sets[$];
  bit fixed_memregions;
  bit override_memregions;
   
  rand int nmemregions;
  rand int unq_val[$];
  rand int memregions_per_ig[$];
  
  constraint c1 {
    nmemregions inside {[min_memregions:max_memregions]};
    foreach (unq_val[i]) {
      if(fixed_memregions == 1) {
        unq_val[i] == i;
      } else {
         unq_val[i] inside {[0:nmemregions-1]};
      }
      foreach (unq_val[j]) {
        (i != j) -> unq_val[i] != unq_val[j];
      }
    }
      unq_val.size() == nmemregions;
      foreach (memregions_per_ig[i])
        if((ig_sets.size()) == 1) {
          memregions_per_ig[i] == nmemregions;
        } else if((nmemregions/ig_sets.size()) > 1 && (override_memregions != 1)) {
          memregions_per_ig[i] inside {[2: nmemregions - 1]};// Assign Coh and NoCoh both memory regions to Interleave Group
        } else {
          memregions_per_ig[i] inside {[1: nmemregions - 1]};
        }
      memregions_per_ig.size() == ig_sets.size(); //no sys dii
      memregions_per_ig.sum()  == nmemregions;
      solve unq_val before memregions_per_ig;
      solve nmemregions before unq_val;
  }

   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   //
   // Function : new
   //
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   function new();
      fixed_memregions = $test$plusargs("fixed_memregions");
      override_memregions = $test$plusargs("override_memregions");
   endfunction: new

  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Function : print 
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  function void print();
    string s;
    int init_val, sum;
    string ext_mem_path;

    integer outfile;
    string line;
    int num;

    init_val = 0;
    sum = 0;
    //////////////////////////////////////////////
    //Debug helper prints
    //$sformat(s, "%s unq_val: ", s);
    //foreach (unq_val[i]) 
    //  $sformat(s, "%s %0d", s, unq_val[i]);
    //////////////////////////////////////////////
  
    $sformat(s, "%s Total number of IGs: %0d \n", s, memregions_per_ig.size());
    $sformat(s,
        "%s Number of interleaved memory regions associated per IG: ", s);
    foreach (memregions_per_ig[i])
      $sformat(s, "%s %0d", s, memregions_per_ig[i]);
    $sformat(s, "%s \n", s);

    if($test$plusargs("override_memregions"))begin //use this plusarg only when need to reconfigure address map and also provide an external file path
      <%if(obj.enInternalCode){%>
            <%if(obj.mem_file_path && obj.mem_file_path !== ""){%>
                ext_mem_path = "<%=obj.mem_file_path%>";
            <%}else{%>
                <%if(obj.CDN){%>
                    ext_mem_path = {getenv("PROJ_HOME"), "/tb/xsim/.sanity/memregions.txt"};
                <%}else{%>
                    ext_mem_path = {getenv("PROJ_HOME"), "/tb/vcs/.sanity/memregions.txt"};
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
      $fgets(line,outfile);
      $fscanf(outfile,"%s",line);
      $fscanf(outfile,"%s",line);
      foreach (unq_val[i]) begin
        $fscanf(outfile,"%d",num);
        unq_val[i] = num ;       // here configuring mappedMemoryRegionsToInterleaveGroup
      end
    end
    
    foreach (memregions_per_ig[i]) begin
      $sformat(s, "%s Memory Regions associated to IG[%0d]: ", s, i);
      sum = sum + memregions_per_ig[i];
      for (int j = init_val; j < sum; ++j) begin
        `ASSERT(j < unq_val.size());
        $sformat(s, "%s %0d", s, unq_val[j]);
      end
      $sformat(s, "%s\n", s);
      init_val = init_val + memregions_per_ig[i];
    end

    $display(s);
  endfunction: print
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Function : post_randomize
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  function void post_randomize();
    int q[$];
    
    q = unq_val.unique();
    `ASSERT(unq_val.size() == q.size());
    `ASSERT(memregions_per_ig.sum() == nmemregions);
  endfunction: post_randomize
 
endclass: memregions_per_ig

