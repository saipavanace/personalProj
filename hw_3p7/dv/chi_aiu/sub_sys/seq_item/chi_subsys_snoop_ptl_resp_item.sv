class chi_subsys_snoop_ptl_resp_item extends chi_subsys_snoop_base_item;
   `svt_xvm_object_utils(chi_subsys_snoop_ptl_resp_item)

   bit force_snpdataptl=0;
   constraint c_snoop_resp_type {
      if (force_snpdataptl > 0) {
         foreach (snpdata_be_pattern[index]){
            snpdata_be_pattern[index] dist {
               BE_ZEROS          := 0,
               BE_ONES           := 0,
               BE_PARTIAL_DATA   := 100
            };
         }
      }
      snp_rsp_datatransfer dist {
         0 := 20,
         1 := 80
      };
   }
   function new(string name = "chi_subsys_snoop_ptl_resp_item");
      super.new(name);
   endfunction: new

   function void pre_randomize();
      super.pre_randomize();
      if(!$value$plusargs("force_snpdataptl=%0d", force_snpdataptl))
         force_snpdataptl = 0;
   endfunction : pre_randomize
   function void post_randomize();
      super.post_randomize();
      if(force_snpdataptl>0) begin
         this.byte_enable[0] = 'h0;
         //foreach (byte_enable[idx]) begin
         //   $urandom(byte_enable[idx]);
         //end
      end
   endfunction : post_randomize

endclass: chi_subsys_snoop_ptl_resp_item
