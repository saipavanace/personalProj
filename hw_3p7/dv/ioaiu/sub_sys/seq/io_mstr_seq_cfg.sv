class io_mstr_seq_cfg  extends mstr_seq_cfg;

    `uvm_object_utils(io_mstr_seq_cfg );
    int core_id = -1; //should specify the core for multicore IOAIU, else -1
    int num_read;
    int num_write;
    //Read txns
    int rdnosnp;
    int rdonce;
    int rdcln;
    int rdnotshrddty;
    int rdshrd;
    int rdunq;
    int clnunq;
    int mkunq;
    int clnshrd;
    int clninvld;
    int mkinvld;
    int clnshardpersist;
    int rdoncemakeinvld;
    int rdonceclinvld;
    
    //Write txns
    int wrnosnp;
    int wrunq;
    int wrlnunq;
    int wrbk;
    int wrcln;
    int wrevct;
    int evct;

    //DVM txns
    int dvmsync;
    int dvmnonsync;
    
    int stshonceshrd;
    int stshonceunq; 
    int wrunqptlstsh;
    int wrunqfullstsh;

    //Atomic txns
    int atmstr;
    int atmld;
    int atmcmp;
    int atmswp;
    //fsys inhouse
    int rd_bar;
    int k_num_read_req;
    int k_num_write_req;
    int no_updates;
    int stshtrans;
    bit enable_ace_dvmsync;

function string print();
    string s;
    if (nativeif != "axi4") begin 
        s = $sformatf("RD TXN: %0d - rdnosnp:%0d rdonce:%0d rdcln:%0d rdnotshrddty:%0d rdshrd:%0d rdunq:%0d clnunq:%0d mkunq:%0d clnshrd:%0d clninvld:%0d mkinvld:%0d clnshardpersist:%0d rdoncemakeinvld:%0d rdonceclinvld:%0d ",k_num_read_req, rdnosnp, rdonce, rdcln, rdnotshrddty, rdshrd, rdunq,clnunq,mkunq,clnshrd,clninvld,mkinvld,clnshardpersist,rdoncemakeinvld,rdonceclinvld);
        s = $sformatf("%0s WR TXN: %0d - wrnosnp:%0d wrunq:%0d wrlnunq:%0d wrbk:%0d wrcln:%0d wrevct:%0d evct:%0d stshonceshrd:%0d stshonceunq:%0d wrunqptlstsh:%0d wrunqfullstsh:%0d atmstr:%0d atmld:%0d atmcmp:%0d atmswp:%0d", s,k_num_write_req, wrnosnp, wrunq, wrlnunq,wrbk,wrcln,wrevct,evct,stshonceshrd,stshonceunq,wrunqptlstsh,wrunqfullstsh,atmstr,atmld,atmcmp,atmswp);
    end else begin 
        s = $sformatf("coreid:%d RD TXN: %0d rdnosnp:%0d rdonce:%0d WR TXN: %0d wrnosnp:%0d wrunq:%0d", core_id,k_num_read_req, rdnosnp, rdonce,k_num_write_req, wrnosnp, wrunq);
    end
    return s;
endfunction:print

 function void dis_all_txn_wts();
     //Read txns
      rdnosnp         =0;
      rdonce          =0;
      rdcln           =0;
      rdnotshrddty    =0;
      rdshrd          =0;
      rdunq           =0;
      clnunq          =0;
      mkunq           =0;
      clnshrd         =0;
      clninvld        =0;
      mkinvld         =0;
      clnshardpersist =0;
      rdoncemakeinvld =0;
      rdonceclinvld   =0;

      //DVM txns
      dvmsync         =0;
      dvmnonsync      =0;
      

      //Write txns
      wrnosnp         =0;
      wrunq           =0;
      wrlnunq         =0;
      wrbk            =0;
      wrcln           =0;
      wrevct          =0;
      evct            =0;
      
      stshonceshrd    =0;
      stshonceunq     =0; 
      wrunqptlstsh    =0;
      wrunqfullstsh   =0;

      //Atomic txns
      atmstr          =0;
      atmld           =0;
      atmcmp          =0;
      atmswp          =0;

      rd_bar         =0;
      k_num_read_req =0;
      k_num_write_req=0;
      no_updates     =0;
      stshtrans      =0;
      enable_ace_dvmsync=0;
  endfunction: dis_all_txn_wts
 
function void en_all_txn_wts();
      if (nativeif == "axi4" || nativeif == "axi5" || nativeif == "ace-lite" || nativeif == "acelite-e" || nativeif == "ace" || nativeif == "ace5") 
      begin
         rdnosnp         =1;
         rdonce          =1;
         wrnosnp         =1;
         wrunq           =1;
      end
      if (nativeif == "ace" || nativeif == "ace5") begin
         rdcln           =1;
         rdnotshrddty    =1;
         rdshrd          =1;
         rdunq           =1;
         clnunq          =1;
         mkunq           =1;
         wrbk            =1;
         wrcln           =1;
         wrevct          =1;
         evct            =1;
      end
      if ((addrMgrConst::io_subsys_dvm_enable_a[funitid]) && (nativeif == "ace" || nativeif == "ace5" || nativeif == "acelite-e")) begin
         //DVM Txns
         //FIXME update after every test has been updated
         dvmsync         =1;
         dvmnonsync      =1;
      end
      if (nativeif == "ace-lite" || nativeif == "acelite-e" || nativeif == "ace" || nativeif == "ace5") begin
         clnshrd         =1;
         clninvld        =1;
         mkinvld         =1;
         wrlnunq         =1;
      end
      if (nativeif == "acelite-e") begin
         clnshardpersist =1;
         rdoncemakeinvld =1;
         rdonceclinvld   =1;
         stshonceshrd   = 1;
         stshonceunq    = 1; 
         wrunqptlstsh   = 1;
         wrunqfullstsh  = 1;
       end
    
      if (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 0) begin 
       //Atomic txns
         atmstr          =0;
         atmld           =0;
         atmcmp          =0;
         atmswp          =0;
      end
      else if (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1) begin 
       //Atomic txns
         atmstr          =1;
         atmld           =1;
         atmcmp          =1;
         atmswp          =1;
      end
    endfunction: en_all_txn_wts

     function void diss_ill_wts_owo();
         rdoncemakeinvld= 0;
	 rdonceclinvld = 0; 
	 clnshardpersist =0;
	 wrunqptlstsh    = 0;
	 wrunqfullstsh   = 0;
	 stshonceshrd = 0;
	 stshonceunq    = 0;
	 stshtrans  = 0;
	 clnshrd         = 0;
	 clninvld        = 0;
	 mkinvld         = 0;
	 dvmsync         =0;
	 dvmnonsync      =0;


      endfunction: diss_ill_wts_owo
    
     function void process_cmdline_args();
      super.process_cmdline_args();
      if(!override_num_txns_from_test) begin
          $value$plusargs("ioaiu_num_trans=%d", num_txns);
      end 
      // TODO All txn weights for fsys inhouse vip -ace,acelite,acelite-e,axi4
      `ifndef USE_VIP_SNPS
          `ifndef USE_VIP_SNPS_AXI_MASTERS
              process_cmdline_args_inhouse();
          `endif
      `endif
      if ($test$plusargs("process_cmdline_args_snps")) process_cmdline_args_snps();
      if ($test$plusargs("en_all_txn_wts")) en_all_txn_wts();
      if ($test$plusargs("dis_all_txn_wts")) dis_all_txn_wts();
      if (addrMgrConst::io_subsys_owo_en[ioaiu_idx] == 1) begin 
          diss_ill_wts_owo(); 	          
      end 

        $value$plusargs("num_write=%d", num_write);
        if($value$plusargs("num_read=%d", num_read))begin
           num_read = (num_txns*num_read)/(num_write+num_read); 
           k_num_read_req = num_read;
        end
   
        if($value$plusargs("num_write=%d", num_write))begin
          num_write = (num_txns*num_write)/(num_write+num_read);
          k_num_write_req = num_write;
        end 
        //Read Txn
        $value$plusargs("rdnosnp=%d", rdnosnp);
        $value$plusargs("rdonce=%d", rdonce);
        $value$plusargs("rdcln=%d", rdcln);
        $value$plusargs("rdnotshrddty=%d", rdnotshrddty);
        $value$plusargs("rdshrd=%d", rdshrd);
        $value$plusargs("rdunq=%d", rdunq);
        $value$plusargs("clnunq=%d", clnunq);
        $value$plusargs("mkunq=%d", mkunq);
        $value$plusargs("clnshrd=%d", clnshrd);
        $value$plusargs("clninvld=%d", clninvld);
        $value$plusargs("mkinvld=%d", mkinvld);

        $value$plusargs("clnshardpersist=%d", clnshardpersist);
        $value$plusargs("rdoncemakeinvld=%d", rdoncemakeinvld);
        $value$plusargs("rdonceclinvld=%d", rdonceclinvld);
        
        //DVM Txns
        $value$plusargs("dvmsync=%d", dvmsync);
        $value$plusargs("dvmnonsync=%d", dvmnonsync);

        //Write Txn
        $value$plusargs("wrnosnp=%d", wrnosnp);
        $value$plusargs("wrunq=%d", wrunq);
        $value$plusargs("wrlnunq=%d", wrlnunq);
        $value$plusargs("wrbk=%d", wrbk);
        $value$plusargs("wrcln=%d", wrcln);
        $value$plusargs("wrevct=%d", wrevct);
        $value$plusargs("evct=%d", evct);
        $value$plusargs("stshonceshrd=%d", stshonceshrd);
        $value$plusargs("stshonceunq=%d", stshonceunq);
        $value$plusargs("wrunqptlstsh=%d", wrunqptlstsh);
        $value$plusargs("wrunqfullstsh=%d", wrunqfullstsh);

        //Atomic txns
        $value$plusargs("atmstr=%d", atmstr);
        $value$plusargs("atmld=%d", atmld);
        $value$plusargs("atmcmp=%d", atmcmp);
        $value$plusargs("atmswp=%d", atmswp);

        if($test$plusargs("directed_stash")) begin
            directed_stash_weights();
        end
        //`uvm_info(get_full_name(), $psprintf("DBG3 fn:process_cmdline_args  io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
    endfunction:process_cmdline_args

    function void process_cmdline_args_inhouse();

//Replacable code
      // Knobs
      addr_trans_mgr              m_addr_mgr;
      ncore_memory_map m_mem;
      m_addr_mgr = addr_trans_mgr::get_instance();
      m_mem = m_addr_mgr.get_memory_map_instance();
      //disabling all weights

      dis_all_txn_wts();

      //Assigning all weights as per plusargs
      if ((nativeif == "axi4"|| nativeif == "axi5") && useCache==0) begin //!obj.useCache
        rdnosnp    = 5;
        rdonce     = 0;
      end else begin
        `ifdef PSEUDO_SYS_TB
        rdnosnp    = 0;
        `else
        rdnosnp    = 5;
        `endif
        rdonce     = 5;
      end
      if (nativeif == "ace" || nativeif == "ace5") begin
        rdshrd                          = 5;
        rdcln                           = 5;
        rdnotshrddty                    = 5;
        rdunq                           = 5;
        clnunq                          = 5;
        mkunq                           = 5;
        dvmnonsync                      = 5;
        dvmsync                         = 5;
      end else begin
        rdshrd                          = 0;
        rdcln                           = 0;
        rdnotshrddty                    = 0;
        rdunq                           = 0;
        clnunq                          = 0;
        mkunq                           = 0;
        dvmnonsync                      = 0;
        dvmsync                         = 0;
      end 
        clnshrd                         = 0;
        clninvld                        = 0;
        mkinvld                         = 0;
      if ((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.useCache
        wrnosnp                         = 5;
        wrunq                           = 0;
        wrlnunq                         = 0;
      end else begin
        `ifdef PSEUDO_SYS_TB
        wrnosnp                         = 0;
        `else
        wrnosnp                         = 5;
        `endif
        wrunq                           = 5; // no notion of WRUNQ with AXI4 but seems just to get cohereerenent region address
        wrlnunq                         = (nativeif != "axi4" && nativeif != "axi5")?5:0;
      end
      if (nativeif == "axi5" || nativeif == "axi4" || nativeif == "ace-lite" ||  nativeif == "acelite-e") begin
        wrcln                           = 0;
        wrbk                            = 0;
        evct                            = 0;
        wrevct                          = 0;
      end else begin
        wrcln                           = 5;
        wrbk                            = 5;
        evct                            = 5;
        wrevct                          = 5;
      end
if ($test$plusargs("read_test") || (($test$plusargs("coherent_test"))  && ($test$plusargs("en_excl_txn")))) begin 
                k_num_read_req      = num_txns;
                k_num_write_req     = 0;
            end else if ($test$plusargs("write_test")) begin
                k_num_read_req      = 0;
                k_num_write_req     = num_txns;
            end else if ($test$plusargs("ac_snoop_bkp")) begin
                k_num_read_req      = num_txns;
                k_num_write_req     = num_txns/5;
            end else begin
                k_num_read_req      = num_txns/2;
                k_num_write_req     = num_txns/2;
            end
      //`uvm_info(get_full_name(), $psprintf("DBG0 fn:process_cmdline_args_inhouse io_mstr_seq_cfg %s nativeif %s,useCache:%0d,orderedWriteObservation:%0s",print(),nativeif,useCache,orderedWriteObservation), UVM_LOW);
      if(nativeif == "ace-lite" || nativeif == "acelite-e" || nativeif == "ace" || nativeif == "ace5" || nativeif == "axi4" || nativeif == "axi5") begin //{ 
            if ($test$plusargs("read_test")) begin // {
		if((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.AiuInfo[pidx].useCache / {
                   //no coherent traffic in case of AXI without $
                   if($test$plusargs("coherent_test")) begin
                    k_num_read_req      = 0;
                    k_num_write_req     = 0;
                   end
                   rdnosnp      = 100;
                   rdonce       = 0;
                   wrnosnp      = 0;
                   wrunq        = 0;
                   rdunq        = 0;
                   clnunq       = 0;
                   rdcln        = 0;
                   rdshrd       = 0;
                end else begin // }{
                if($test$plusargs("noncoherent_test")) begin// {
                      wrnosnp      = 0;
                      rdnosnp      = 100;
                      wrlnunq      = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdunq        = 0;
                      rdonce       = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;
                end// }
                else if($test$plusargs("coherent_test")) begin// {
                   rdnosnp      = 0;
                   rdonce       = 100;
                   if($test$plusargs("perf_test")) begin
                      rdunq        = 0;
                      wrlnunq      = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;
                   end
                   wrnosnp      = 0;
                   wrunq        = 0;
                end//}
                else if ($test$plusargs("zero_out_all_read_wts")) begin//{
                   rdnosnp      = 0;
                   rdonce       = 0;
                   rdunq        = 0;
                   mkunq        = 0;
                   clnunq       = 0;
                   rdcln        = 0;
                   rdshrd       = 0;
                   rdnotshrddty = 0;
                   clnshrd      = 0;  
                   clnshardpersist = 0;
                   clninvld      = 0; 
                   mkinvld       = 0; 
                   rdonceclinvld = 0; 
                   rdoncemakeinvld= 0; 
                end //}
                else begin //{
                   rdnosnp      = 50;
                   rdonce       = 50;
                   wrnosnp      = 0;
                   wrunq        = 0;
                end //}
              end //}
           //`uvm_info(get_full_name(), $psprintf("DBG1 fn:process_cmdline_args_inhouse read_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
            end //}
            else if ($test$plusargs("write_test")) begin //{ 
	        if((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.AiuInfo[pidx].useCache {
                   //no coherent traffic in case of AXI without $
                   if($test$plusargs("coherent_test")) begin//{
                    k_num_read_req      = 0;
                    k_num_write_req     = 0;
                   end//}
                   rdnosnp      = 0;
                   rdonce       = 0;
                   wrnosnp      = 100;
                   wrunq        = 0;
                   wrlnunq      = 0;
                end else begin //}{
                if($test$plusargs("noncoherent_test")) begin //{
                      wrnosnp      = 100;
                      rdnosnp      = 0;
                      wrunq        = 0;
                      wrlnunq      = 0;
                      rdunq        = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdonce       = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;
                  
                end//}
                else if($test$plusargs("coherent_test")) begin//{
                   rdnosnp      = 0;
                   rdonce       = 0;
                   wrnosnp      = 0;
                   wrunq        = 5;
                   wrlnunq      = 0;
                end//}
                else begin//{
                   rdnosnp      = 0;
                   rdonce       = 0;
                   wrnosnp      = 35;
                   wrunq        = 35;
                   wrlnunq      = (nativeif != "axi4" && nativeif != "axi5")?30:0;
                end//}
              end//}
           //`uvm_info(get_full_name(), $psprintf("DBG1 fn:process_cmdline_args_inhouse write_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
            end else begin ////} if ($test$plusargs("write_test")) {
		 if((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.AiuInfo[pidx].useCache //{
                    //no coherent traffic in case of AXI without $
                    if($test$plusargs("coherent_test")) begin
                       k_num_read_req      = 0;
                       k_num_write_req     = 0;
                    end
                    rdnosnp      = 100;
                    rdonce       = 0;
                    wrnosnp      = 100;
                    wrunq        = 0;
                end else if((nativeif == "axi4" || nativeif == "axi5") && useCache==1 ) begin//obj.AiuInfo[pidx].useCache //}{
                    if($test$plusargs("noncoherent_test")) begin //{
                       rdnosnp      = 100;
                       rdonce       = 0;
                       wrnosnp      = 100;
                       wrunq        = 0;   
                    end//}
                    else begin //{
                       rdnosnp      = 100;
                       rdonce       = 100;
                       wrnosnp      = 100;
                       wrunq        = 100;   
                    end//}
                end else begin //}{
                if($test$plusargs("noncoherent_test")) begin //{
                  if (nativeif != "axi4" && nativeif != "axi5") begin //{

                      wrnosnp      = 100;
                      rdnosnp      = 100;
                      clnunq       = 0;
                      rdshrd       = 0;
                      wrunq        = 0;
                      wrlnunq      = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdunq        = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdunq        = 0;
                      rdonce       = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;              
                   end else begin //}{
                      rdnosnp      = 100;
                      rdonce       = 0;
                      wrnosnp      = 100;
                      wrunq        = 0;
                      wrlnunq      = 0;
                      wrcln        = 0;
                      rdunq        = 0;
                      clnunq       = 0;
                      rdcln        = 0;
                      rdshrd       = 0;
                      rdnotshrddty = 0;
                 end//}
                end //}
                else if($test$plusargs("coherent_test")) begin //{
                    rdnosnp      = 0;
                    rdonce       = 100;
                    wrnosnp      = 0;
                    wrunq        = 100;
                    wrlnunq      = (nativeif != "axi4" && nativeif != "axi5")?100:0;
		    if(nativeif == "ace" || nativeif == "ace5") begin//{
                        rdunq        = 100;
                        rdcln        = 100;
                        rdshrd       = 100;
                        rdnotshrddty = 100;
                    end//}

                    if(nativeif == "acelite-e") begin//{
                    rdonceclinvld = 100; 
                    rdoncemakeinvld= 100; 
                    end//}

                    if($test$plusargs("en_excl_txn")) begin//{
                        rdnosnp      = 0;
                        rdonce       = 0;
                        wrnosnp      = 0;
                        wrunq        = 0;
                        wrlnunq      = 0;
                     if(nativeif == "ace" || nativeif == "ace5") begin//{
                        wrcln           = 0;
                        clnunq          = 100;
                        rdunq           = 0;
                        rdcln           = 100;
                        rdshrd          = 100;
                        rdnotshrddty    = 100;
                        mkunq           = 0;     
                        clnshrd         = 0;  
                        clninvld        = 0; 
                        mkinvld         = 0; 
                        rdonceclinvld   = 0; 
                        rdoncemakeinvld = 0; 
                        clnshardpersist = 0;
                        wrunqptlstsh    = 0;
                        wrunqfullstsh   = 0;
                        stshonceshrd    = 0;
                        stshonceunq     = 0;
                        stshtrans       = 0;
                      end//}
                    end//}
                end //}
                else begin//{
                    if(m_mem.noncoh_reg_maps_to_dii == 0) begin //{
                       rdnosnp      = 100;
                       wrnosnp      = 100;
                    end else begin//}{
                       rdnosnp      = 0;
                       wrnosnp      = 0;
                    end//}
                    if(($test$plusargs("dce_fix_index"))||($test$plusargs("dmi_fix_index")))begin//{
                       rdonce       = 0;
                       wrunq        = 100;
                    end else begin//}{
                       rdonce       = 100;
                       wrunq        = 100;
                    end//}
                    wrlnunq      = (nativeif != "axi4" && nativeif != "axi5")?50:0;
                    if(nativeif == "ace" || nativeif == "ace5") begin//{
                       rdshrd       = 100;
                       rdcln        = 100;
                       rdnotshrddty = 100;
                       rdunq        = 100;
                    end//}
                    if(nativeif == "acelite-e") begin//{
                        rdonceclinvld = 100; 
                        rdoncemakeinvld= 100; 
                        clnshardpersist = 100;
                    end//}

	        end //} else: !if($test$plusargs("coherent_test"))
          end //}
           //`uvm_info(get_full_name(), $psprintf("DBG1 fn:process_cmdline_args_inhouse default io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
     end //} else: !if($test$plusargs("write_test")
     
     if((nativeif == "axi4" || nativeif == "axi5") && useCache==1) begin//{
         if($test$plusargs("all_gpra_ncmode"))  begin
     // TMP avoid send noncoh txn in coh mem region //TODO when gpra random should add constraint with gpra.nc when select addr in noncoh & coh mem region 
            rdonce       = 0;
            wrunq        = 0;
         end
      end //}

      if(nativeif == "ace-lite"  && orderedWriteObservation=="true") begin//{
        clnshrd = 0; 
        clnshardpersist   = 0; 
        clninvld = 0;
        mkinvld = 0;
        wrlnunq = 0;
      end//}
      if(!(nativeif == "axi4" || nativeif == "axi5")) begin//{ 
          if(nativeif == "ace"|| nativeif == "ace5") begin //{
                if ($test$plusargs("use_copyback")) begin//{
                    wrcln        = 100;
                    wrbk         = 100;
                    wrevct       = 100;
                    mkunq        = 100;
                    rdnosnp      = 0;
                    rdonce       = 1;
                    wrnosnp      = 0;
                    wrunq        = 1;
                    wrlnunq      = 0;
                    clnunq       = 0;
                    rdunq        = 100;
                    rdcln        = 100;
                    rdshrd       = 100;
                    rdnotshrddty = 100;   
                    clninvld      = 0; 
                    mkinvld       = 0; 
                    rdonceclinvld = 0; 
                    rdoncemakeinvld= 0; 
                    clnshardpersist = 0;
                    wrunqptlstsh    = 0;
                    wrunqfullstsh   = 0;
                    stshonceshrd = 0;
                    stshonceunq    = 0;
                    stshtrans  = 0;
                end else begin//}{
                    wrcln        = 0;
                    wrbk         = 0;
                    wrevct       = 0;
                end//}
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_inhouse ACE_IF io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
          end //}
          if ($test$plusargs("use_nondata")) begin//{
                if(m_mem.noncoh_reg_maps_to_dii == 0) begin //{
                  clnshrd      = 100;
                  clninvld      = 100;
                  mkinvld       = 100;
                  if(nativeif == "acelite-e" || nativeif == "ace" || nativeif == "ace5") begin//{
                  clnshardpersist = 100;
                  end //}
                end else begin//}{
                   clnshrd      = 0;
                   clninvld      = 0;
                   mkinvld       = 0;
                end//}

                if(nativeif == "ace" || nativeif == "ace5") begin //{
                clnunq       = 50;
                mkunq        = 50;
                evct         = 50;
                no_updates          = 50;
                end //}
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_inhouse use_nondata io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);

            end else begin//}{
                clnunq       = 0;
                clnshrd      = 0;
                clninvld      = 0;
                mkinvld       = 0;
                evct         = 0;
                no_updates          = 0;
                if($test$plusargs("en_excl_txn")) begin//{
                   if(nativeif == "ace" || nativeif == "ace5") begin// {
                       clnunq       = 150;
                   end //} 
                end//}
             end//}
        if(nativeif == "acelite-e") begin // {
                if ($test$plusargs("use_atomic") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    atmstr      = 50;
                    atmld       = 50;
                    atmswp     = 10;
                    atmcmp     = 10;
                end else begin//}{
                    atmstr      = 0;
                    atmld       = 0;
                    atmswp     = 0;
                    atmcmp     = 0;
                end //} else: !if($test$plusargs("use_atomic"))
                if ($test$plusargs("use_atomic_compare") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    rdonceclinvld     = 0; 
                    rdoncemakeinvld   = 0; 
                    clnshardpersist   = 0;
                    atmstr            = 0;
                    atmld             = 0;
                    atmswp            = 0;
                    atmcmp            = 400;
                end//}
                if ($test$plusargs("use_stash")) begin//{
                    wrunqptlstsh    = 100;
                    wrunqfullstsh   = 100;
                    stshonceshrd    = 100;
                    stshonceunq     = 100;
                    stshtrans       = 0;
                end else begin//}{
                    wrunqptlstsh    = 0;
                    wrunqfullstsh   = 0;
                    stshonceshrd = 0;
                    stshonceunq    = 0;
                    stshtrans  = 0;
                end//}
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_inhouse ACELiteE_IF io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
        end //} 
               
        if((addrMgrConst::io_subsys_dvm_enable_a[funitid]) && (nativeif == "ace" || nativeif == "ace5")) begin // {
             if ($test$plusargs("use_dvm")) begin
                 dvmnonsync      = 25;
                 if($test$plusargs("use_ace_dvmsync") && (enable_ace_dvmsync==0)) begin
                 dvmsync     = 20;
	         enable_ace_dvmsync = 1;
                 end else begin
                 dvmsync     = 0;
                 end
                  end else begin
                 dvmnonsync      = 0;
                 dvmsync     = 0;
              end
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_inhouse dvm_enble io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
         end else begin //} {
              dvmnonsync      = 0;
              dvmsync     = 0;
         end// }
         if($test$plusargs("dii_cmo_test")) begin//{
             if (nativeif != "axi4" && nativeif != "axi5") begin // {
                 clnshardpersist = (nativeif == "acelite-e")?100:0;                 
                 clnshrd       = 100;
                 clninvld      = 100;
                 mkinvld       = 100;
              end else begin //} {
                 clnshardpersist = 0;                 
                 clnshrd         = 0;
                 clninvld        = 0;
                 mkinvld         = 0;
               end //} 
                 wrnosnp      = 10;
                 rdnosnp      = 10;
                 rdonce       = 0;
                 rdshrd       = 0;
                 rdcln        = 0;
                 rdnotshrddty = 0;
                 rdunq        = 0;
                 clnunq       = 0;
                 mkunq        = 0;
                 dvmnonsync   = 0;
                 dvmsync      = 0;
                 rd_bar       = 0;
                 rdonceclinvld    = 0;
                 rdoncemakeinvld  = 0;
                 clnshardpersist  = 0;
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_inhouse dii_cmo_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
        end //}
        if(nativeif == "ace" || nativeif == "ace5") begin // {
	    if ($test$plusargs("nouse_unq_invld")) begin
               rdonce       = 0;
               rdunq        = 0;
               wrnosnp      = 0;
               wrunq        = 0;
               wrlnunq      = 0;
	     end
	end //}
        if(nativeif == "ace-lite" || nativeif == "acelite-e" || nativeif == "axi4" || nativeif == "axi5") begin // { 
             if ($test$plusargs("nouse_unq_invld")) begin
                 k_num_read_req      = num_txns;
                 k_num_write_req     = 0;
                 wrunq               = 0;
                 wrlnunq             = 0;
	         rdonceclinvld       = 0; 
                 rdoncemakeinvld     = 0; 
                 clnshardpersist     = 0;
             end
	 end //}

         if($test$plusargs("directed_dtwmrg_test")) begin//{
             if(nativeif == "ace" || nativeif == "ace5") begin // { 
                 if($test$plusargs("ace1_clnunique")) begin//TODO acefunitid
                 clnunq       = 100;
                 rdshrd       = 0;
                 rdcln        = 0;
                 rdnotshrddty = 0;
                 rdunq        = 0;
                 end else begin
                 clnunq       = 0;
                 rdshrd       = 100;
                 rdcln        = 100;
                 rdnotshrddty = 100;
                 rdunq        = 100;
                 end
                 rdonce       = 0;
                 rdonceclinvld = 0;
                 wrunqptlstsh    = 0;
             end else if (nativeif == "acelite-e") begin //}{
                 rdonce       = 100;
                 rdonceclinvld = 100;
                 wrunqptlstsh    = 100;
                 clnunq       = 0;
                 rdshrd       = 0;
                 rdcln        = 0;
                 rdnotshrddty = 0;
                 rdunq        = 0;
              end // } 
                 clnshardpersist = 0;                 
                 clnshrd      = 0;
                 clninvld      = 0;
                 mkinvld       = 0;
                 wrnosnp      = 1;
                 rdnosnp      = 1;
                 mkunq        = 0;
                 dvmnonsync      = 0;
                 dvmsync     = 0;
                 rd_bar        = 0;
                 rdoncemakeinvld = 0;
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_inhouse directed_dtwmrg_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);

              end//}

            end// } 
            if (addrMgrConst::io_subsys_owo_en[ioaiu_idx] == 1) begin 
               clnshrd = 0;
               clninvld = 0;
               mkinvld = 0;
               clnshardpersist = 0;
               //#Stimulus.IOAIU.OWO.RdWrAtmSnp
               if ($test$plusargs("use_atomic") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    atmstr      = 50;
                    atmld       = 50;
                    atmswp     = 10;
                    atmcmp     = 10;
                end else begin//}{
                    atmstr      = 0;
                    atmld       = 0;
                    atmswp     = 0;
                    atmcmp     = 0;
                end //} else: !if($test$plusargs("use_atomic"))
                if ($test$plusargs("use_atomic_compare") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    atmstr            = 0;
                    atmld             = 0;
                    atmswp            = 0;
                    atmcmp            = 400;
                end//}
            end
             // `uvm_info(get_full_name(), $psprintf("DBG3 fn:process_cmdline_args_inhouse  io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
          end  // } 

    endfunction:process_cmdline_args_inhouse
    //CONC-16253 - This code will execute for snps vip on fsys and io_subsys TB when plusarg process_cmdline_args_snps provided in test
    function void process_cmdline_args_snps();

      // Knobs
      addr_trans_mgr              m_addr_mgr;
      ncore_memory_map m_mem;
      m_addr_mgr = addr_trans_mgr::get_instance();
      m_mem = m_addr_mgr.get_memory_map_instance();
      //disabling all weights

      dis_all_txn_wts();

      //Assigning all weights as per plusargs
      if ((nativeif == "axi4"|| nativeif == "axi5") && useCache==0) begin //!obj.useCache
        rdnosnp    = 1;
        rdonce     = 0;
      end else begin
        `ifdef PSEUDO_SYS_TB
        rdnosnp    = 0;
        `else
        rdnosnp    = 1;
        `endif
        rdonce     = 1;
      end
      if (nativeif == "ace" || nativeif == "ace5") begin
        rdshrd                          = 1;
        rdcln                           = 1;
        rdnotshrddty                    = 1;
        rdunq                           = 1;
        clnunq                          = 1;
        mkunq                           = 1;
        dvmnonsync                      = 1;
        dvmsync                         = 1;
      end else begin
        rdshrd                          = 0;
        rdcln                           = 0;
        rdnotshrddty                    = 0;
        rdunq                           = 0;
        clnunq                          = 0;
        mkunq                           = 0;
        dvmnonsync                      = 0;
        dvmsync                         = 0;
      end 
        clnshrd                         = 0;
        clninvld                        = 0;
        mkinvld                         = 0;
      if ((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.useCache
        wrnosnp                         = 1;
        wrunq                           = 0;
        wrlnunq                         = 0;
      end else begin
        `ifdef PSEUDO_SYS_TB
        wrnosnp                         = 0;
        `else
        wrnosnp                         = 1;
        `endif
        wrunq                           = 1; // no notion of WRUNQ with AXI4 but seems just to get cohereerenent region address
        wrlnunq                         = (nativeif != "axi4" && nativeif != "axi5")?1:0;
      end
      if (nativeif == "axi5" || nativeif == "axi4" || nativeif == "ace-lite" ||  nativeif == "acelite-e") begin
        wrcln                           = 0;
        wrbk                            = 0;
        evct                            = 0;
        wrevct                          = 0;
      end else begin
        wrcln                           = 1;
        wrbk                            = 1;
        evct                            = 1;
        wrevct                          = 1;
      end
if ($test$plusargs("read_test") || (($test$plusargs("coherent_test"))  && ($test$plusargs("en_excl_txn")))) begin 
                k_num_read_req      = num_txns;
                k_num_write_req     = 0;
            end else if ($test$plusargs("write_test")) begin
                k_num_read_req      = 0;
                k_num_write_req     = num_txns;
            end else if ($test$plusargs("ac_snoop_bkp")) begin
                k_num_read_req      = num_txns;
                k_num_write_req     = num_txns/5;
            end else begin
                k_num_read_req      = num_txns/2;
                k_num_write_req     = num_txns/2;
            end
      //`uvm_info(get_full_name(), $psprintf("DBG0 fn:process_cmdline_args_snps io_mstr_seq_cfg %s nativeif %s,useCache:%0d,orderedWriteObservation:%0s",print(),nativeif,useCache,orderedWriteObservation), UVM_LOW);
      if(nativeif == "ace-lite" || nativeif == "acelite-e" || nativeif == "ace" || nativeif == "ace5" || nativeif == "axi4" || nativeif == "axi5") begin //{ 
            if ($test$plusargs("read_test")) begin // {
		if((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.AiuInfo[pidx].useCache / {
                   //no coherent traffic in case of AXI without $
                   if($test$plusargs("coherent_test")) begin
                    k_num_read_req      = 0;
                    k_num_write_req     = 0;
                   end
                   rdnosnp      = 1;
                   rdonce       = 0;
                   wrnosnp      = 0;
                   wrunq        = 0;
                   rdunq        = 0;
                   clnunq       = 0;
                   rdcln        = 0;
                   rdshrd       = 0;
                end else begin // }{
                if($test$plusargs("noncoherent_test")) begin// {
                      wrnosnp      = 0;
                      rdnosnp      = 1;
                      wrlnunq      = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdunq        = 0;
                      rdonce       = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;
                end// }
                else if($test$plusargs("coherent_test")) begin// {
                   rdnosnp      = 0;
                   rdonce       = 1;
                   if($test$plusargs("perf_test")) begin
                      rdunq        = 0;
                      wrlnunq      = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;
                   end
                   wrnosnp      = 0;
                   wrunq        = 0;
                end//}
                else if ($test$plusargs("zero_out_all_read_wts")) begin//{
                   rdnosnp      = 0;
                   rdonce       = 0;
                   rdunq        = 0;
                   mkunq        = 0;
                   clnunq       = 0;
                   rdcln        = 0;
                   rdshrd       = 0;
                   rdnotshrddty = 0;
                   clnshrd      = 0;  
                   clnshardpersist = 0;
                   clninvld      = 0; 
                   mkinvld       = 0; 
                   rdonceclinvld = 0; 
                   rdoncemakeinvld= 0; 
                end //}
                else begin //{
                   rdnosnp      = 1;
                   rdonce       = 1;
                   wrnosnp      = 0;
                   wrunq        = 0;
                end //}
              end //}
           //`uvm_info(get_full_name(), $psprintf("DBG1 fn:process_cmdline_args_snps read_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
            end //}
            else if ($test$plusargs("write_test")) begin //{ 
	        if((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.AiuInfo[pidx].useCache {
                   //no coherent traffic in case of AXI without $
                   if($test$plusargs("coherent_test")) begin//{
                    k_num_read_req      = 0;
                    k_num_write_req     = 0;
                   end//}
                   rdnosnp      = 0;
                   rdonce       = 0;
                   wrnosnp      = 1;
                   wrunq        = 0;
                   wrlnunq      = 0;
                end else begin //}{
                if($test$plusargs("noncoherent_test")) begin //{
                      wrnosnp      = 1;
                      rdnosnp      = 0;
                      wrunq        = 0;
                      wrlnunq      = 0;
                      rdunq        = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdonce       = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;
                  
                end//}
                else if($test$plusargs("coherent_test")) begin//{
                   rdnosnp      = 0;
                   rdonce       = 0;
                   wrnosnp      = 0;
                   wrunq        = 1;
                   wrlnunq      = 0;
                end//}
                else begin//{
                   rdnosnp      = 0;
                   rdonce       = 0;
                   wrnosnp      = 1;
                   wrunq        = 1;
                   wrlnunq      = (nativeif != "axi4" && nativeif != "axi5")?1:0;
                end//}
              end//}
           //`uvm_info(get_full_name(), $psprintf("DBG1 fn:process_cmdline_args_snps write_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
            end else begin ////} if ($test$plusargs("write_test")) {
		 if((nativeif == "axi4" || nativeif == "axi5") && useCache==0) begin//!obj.AiuInfo[pidx].useCache //{
                    //no coherent traffic in case of AXI without $
                    if($test$plusargs("coherent_test")) begin
                       k_num_read_req      = 0;
                       k_num_write_req     = 0;
                    end
                    rdnosnp      = 1;
                    rdonce       = 0;
                    wrnosnp      = 1;
                    wrunq        = 0;
                end else begin //}{
                if($test$plusargs("noncoherent_test")) begin //{
                  if (nativeif != "axi4" && nativeif != "axi5") begin //{

                      wrnosnp      = 1;
                      rdnosnp      = 1;
                      clnunq       = 0;
                      rdshrd       = 0;
                      wrunq        = 0;
                      wrlnunq      = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdunq        = 0;
                      clnunq       = 0;
                      rdshrd       = 0;
                      rdcln        = 0;
                      rdnotshrddty = 0;
                      rdunq        = 0;
                      rdonce       = 0;
                      rdonceclinvld = 0;
                      wrunqptlstsh    = 0;
                      clnshardpersist = 0;                 
                      clnshrd      = 0;
                      clninvld      = 0;
                      mkinvld       = 0;
                      mkunq        = 0;
                      dvmnonsync      = 0;
                      dvmsync     = 0;
                      rd_bar        = 0;
                      rdoncemakeinvld = 0;              
                   end else begin //}{
                      rdnosnp      = 1;
                      rdonce       = 0;
                      wrnosnp      = 1;
                      wrunq        = 0;
                      wrlnunq      = 0;
                      wrcln        = 0;
                      rdunq        = 0;
                      clnunq       = 0;
                      rdcln        = 0;
                      rdshrd       = 0;
                      rdnotshrddty = 0;
                 end//}
                end //}
                else if($test$plusargs("coherent_test")) begin //{
                    rdnosnp      = 0;
                    rdonce       = 1;
                    wrnosnp      = 0;
                    wrunq        = 1;
                    wrlnunq      = (nativeif != "axi4" && nativeif != "axi5")?100:0;
		    if(nativeif == "ace" || nativeif == "ace5") begin//{
                        rdunq        = 1;
                        rdcln        = 1;
                        rdshrd       = 1;
                        rdnotshrddty = 1;
                    end//}

                    if(nativeif == "acelite-e") begin//{
                    rdonceclinvld = 1; 
                    rdoncemakeinvld= 1; 
                    end//}

                    if($test$plusargs("en_excl_txn")) begin//{
                        rdnosnp      = 0;
                        rdonce       = 0;
                        wrnosnp      = 0;
                        wrunq        = 0;
                        wrlnunq      = 0;
                     if(nativeif == "ace" || nativeif == "ace5") begin//{
                        wrcln           = 0;
                        clnunq          = 1;
                        rdunq           = 0;
                        rdcln           = 1;
                        rdshrd          = 1;
                        rdnotshrddty    = 1;
                        mkunq           = 0;     
                        clnshrd         = 0;  
                        clninvld        = 0; 
                        mkinvld         = 0; 
                        rdonceclinvld   = 0; 
                        rdoncemakeinvld = 0; 
                        clnshardpersist = 0;
                        wrunqptlstsh    = 0;
                        wrunqfullstsh   = 0;
                        stshonceshrd    = 0;
                        stshonceunq     = 0;
                        stshtrans       = 0;
                      end//}
                    end//}
                end //}
                else begin//{
                    if(m_mem.noncoh_reg_maps_to_dii == 0) begin //{
                       rdnosnp      = 1;
                       wrnosnp      = 1;
                    end else begin//}{
                       rdnosnp      = 0;
                       wrnosnp      = 0;
                    end//}
                    if(($test$plusargs("dce_fix_index"))||($test$plusargs("dmi_fix_index")))begin//{
                       rdonce       = 0;
                       wrunq        = 1;
                    end else begin//}{
                       rdonce       = 1;
                       wrunq        = 1;
                    end//}
                    wrlnunq      = (nativeif != "axi4" && nativeif != "axi5")?50:0;
                    if(nativeif == "ace" || nativeif == "ace5") begin//{
                       rdshrd       = 1;
                       rdcln        = 1;
                       rdnotshrddty = 1;
                       rdunq        = 1;
                    end//}
                    if(nativeif == "acelite-e") begin//{
                        rdonceclinvld = 1; 
                        rdoncemakeinvld= 1; 
                        clnshardpersist = 1;
                    end//}

	        end //} else: !if($test$plusargs("coherent_test"))
          end //}
           //`uvm_info(get_full_name(), $psprintf("DBG1 fn:process_cmdline_args_snps default io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
     end //} else: !if($test$plusargs("write_test")
     
     if((nativeif == "axi4" || nativeif == "axi5") && useCache==1) begin//{
         if($test$plusargs("all_gpra_ncmode"))  begin
     // TMP avoid send noncoh txn in coh mem region //TODO when gpra random should add constraint with gpra.nc when select addr in noncoh & coh mem region 
            rdonce       = 0;
            wrunq        = 0;
         end
      end //}

      if(nativeif == "ace-lite"  && orderedWriteObservation=="true") begin//{
        clnshrd = 0; 
        clnshardpersist   = 0; 
        clninvld = 0;
        mkinvld = 0;
        wrlnunq = 0;
      end//}
      if(!(nativeif == "axi4" || nativeif == "axi5")) begin//{ 
          if(nativeif == "ace"|| nativeif == "ace5") begin //{
                if ($test$plusargs("use_copyback")) begin//{
                    wrcln        = 100;
                    wrbk         = 100;
                    wrevct       = 100;
                    mkunq        = 100;
                    rdnosnp      = 0;
                    rdonce       = 1;
                    wrnosnp      = 0;
                    wrunq        = 1;
                    wrlnunq      = 0;
                    clnunq       = 0;
                    rdunq        = 100;
                    rdcln        = 100;
                    rdshrd       = 100;
                    rdnotshrddty = 100;   
                    clninvld      = 0; 
                    mkinvld       = 0; 
                    rdonceclinvld = 0; 
                    rdoncemakeinvld= 0; 
                    clnshardpersist = 0;
                    wrunqptlstsh    = 0;
                    wrunqfullstsh   = 0;
                    stshonceshrd = 0;
                    stshonceunq    = 0;
                    stshtrans  = 0;
                end else begin//}{
                    wrcln        = 0;
                    wrbk         = 0;
                    wrevct       = 0;
                end//}
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_snps ACE_IF io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
          end //}
          if ($test$plusargs("use_nondata")) begin//{
                if(m_mem.noncoh_reg_maps_to_dii == 0) begin //{
                  clnshrd      = 1;
                  clninvld      = 1;
                  mkinvld       = 1;
                  if(nativeif == "acelite-e" || nativeif == "ace" || nativeif == "ace5") begin//{
                  clnshardpersist = 1;
                  end //}
                end else begin//}{
                   clnshrd      = 0;
                   clninvld      = 0;
                   mkinvld       = 0;
                end//}

                if(nativeif == "ace" || nativeif == "ace5") begin //{
                clnunq       = 1;
                mkunq        = 1;
                evct         = 1;
                no_updates          = 1;
                end //}
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_snps use_nondata io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);

            end else begin//}{
                clnunq       = 0;
                clnshrd      = 0;
                clninvld      = 0;
                mkinvld       = 0;
                evct         = 0;
                no_updates          = 0;
                if($test$plusargs("en_excl_txn")) begin//{
                   if(nativeif == "ace" || nativeif == "ace5") begin// {
                       clnunq       = 150;
                   end //} 
                end//}
             end//}
        if(nativeif == "acelite-e") begin // {
                if ($test$plusargs("use_atomic") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    atmstr      = 5;
                    atmld       = 5;
                    atmswp     = 1;
                    atmcmp     = 1;
                end else begin//}{
                    atmstr      = 0;
                    atmld       = 0;
                    atmswp     = 0;
                    atmcmp     = 0;
                end //} else: !if($test$plusargs("use_atomic"))
                if ($test$plusargs("use_atomic_compare") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    rdonceclinvld     = 0; 
                    rdoncemakeinvld   = 0; 
                    clnshardpersist   = 0;
                    atmstr            = 0;
                    atmld             = 0;
                    atmswp            = 0;
                    atmcmp            = 400;
                end//}
                if ($test$plusargs("use_stash")) begin//{
                    wrunqptlstsh    = 1;
                    wrunqfullstsh   = 1;
                    stshonceshrd    = 1;
                    stshonceunq     = 1;
                    stshtrans       = 0;
                end else begin//}{
                    wrunqptlstsh    = 0;
                    wrunqfullstsh   = 0;
                    stshonceshrd = 0;
                    stshonceunq    = 0;
                    stshtrans  = 0;
                end//}
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_snps ACELiteE_IF io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
        end //} 
               
        if((addrMgrConst::io_subsys_dvm_enable_a[funitid]) && (nativeif == "ace" || nativeif == "ace5")) begin // {
             if ($test$plusargs("use_dvm")) begin
                 dvmnonsync      = 1;
                 if($test$plusargs("use_ace_dvmsync") && (enable_ace_dvmsync==0)) begin
                 dvmsync     = 1;
	         enable_ace_dvmsync = 1;
                 end else begin
                 dvmsync     = 0;
                 end
                  end else begin
                 dvmnonsync      = 0;
                 dvmsync     = 0;
              end
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_snps dvm_enble io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
         end else begin //} {
              dvmnonsync      = 0;
              dvmsync     = 0;
         end// }
         if($test$plusargs("dii_cmo_test")) begin//{
             if (nativeif != "axi4" && nativeif != "axi5") begin // {
                 clnshardpersist = (nativeif == "acelite-e")?100:0;                 
                 clnshrd       = 1;
                 clninvld      = 1;
                 mkinvld       = 1;
              end else begin //} {
                 clnshardpersist = 0;                 
                 clnshrd         = 0;
                 clninvld        = 0;
                 mkinvld         = 0;
               end //} 
                 wrnosnp      = 1;
                 rdnosnp      = 1;
                 rdonce       = 0;
                 rdshrd       = 0;
                 rdcln        = 0;
                 rdnotshrddty = 0;
                 rdunq        = 0;
                 clnunq       = 0;
                 mkunq        = 0;
                 dvmnonsync   = 0;
                 dvmsync      = 0;
                 rd_bar       = 0;
                 rdonceclinvld    = 0;
                 rdoncemakeinvld  = 0;
                 clnshardpersist  = 0;
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_snps dii_cmo_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
        end //}
        if(nativeif == "ace" || nativeif == "ace5") begin // {
	    if ($test$plusargs("nouse_unq_invld")) begin
               rdonce       = 0;
               rdunq        = 0;
               wrnosnp      = 0;
               wrunq        = 0;
               wrlnunq      = 0;
	     end
	end //}
        if(nativeif == "ace-lite" || nativeif == "acelite-e" || nativeif == "axi4" || nativeif == "axi5") begin // { 
             if ($test$plusargs("nouse_unq_invld")) begin
                 k_num_read_req      = num_txns;
                 k_num_write_req     = 0;
                 wrunq               = 0;
                 wrlnunq             = 0;
	         rdonceclinvld       = 0; 
                 rdoncemakeinvld     = 0; 
                 clnshardpersist     = 0;
             end
	 end //}

         if($test$plusargs("directed_dtwmrg_test")) begin//{
             if(nativeif == "ace" || nativeif == "ace5") begin // { 
                 if($test$plusargs("ace1_clnunique")) begin//TODO acefunitid
                 clnunq       = 1;
                 rdshrd       = 0;
                 rdcln        = 0;
                 rdnotshrddty = 0;
                 rdunq        = 0;
                 end else begin
                 clnunq       = 0;
                 rdshrd       = 1;
                 rdcln        = 1;
                 rdnotshrddty = 1;
                 rdunq        = 1;
                 end
                 rdonce       = 0;
                 rdonceclinvld = 0;
                 wrunqptlstsh    = 0;
             end else if (nativeif == "acelite-e") begin //}{
                 rdonce       = 1;
                 rdonceclinvld = 1;
                 wrunqptlstsh    = 1;
                 clnunq       = 0;
                 rdshrd       = 0;
                 rdcln        = 0;
                 rdnotshrddty = 0;
                 rdunq        = 0;
              end // } 
                 clnshardpersist = 0;                 
                 clnshrd      = 0;
                 clninvld      = 0;
                 mkinvld       = 0;
                 wrnosnp      = 1;
                 rdnosnp      = 1;
                 mkunq        = 0;
                 dvmnonsync      = 0;
                 dvmsync     = 0;
                 rd_bar        = 0;
                 rdoncemakeinvld = 0;
              //`uvm_info(get_full_name(), $psprintf("DBG2 fn:process_cmdline_args_snps directed_dtwmrg_test io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);

              end//}

            end// } 
            if (addrMgrConst::io_subsys_owo_en[ioaiu_idx] == 1) begin 
               clnshrd = 0;
               clninvld = 0;
               mkinvld = 0;
               clnshardpersist = 0;
               if ($test$plusargs("use_atomic") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    atmstr      = 5;
                    atmld       = 5;
                    atmswp     = 1;
                    atmcmp     = 1;
                end else begin//}{
                    atmstr      = 0;
                    atmld       = 0;
                    atmswp     = 0;
                    atmcmp     = 0;
                end //} else: !if($test$plusargs("use_atomic"))
                if ($test$plusargs("use_atomic_compare") && (addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx] == 1)) begin//{
                    atmstr            = 0;
                    atmld             = 0;
                    atmswp            = 0;
                    atmcmp            = 400;
                end//}
            end
             // `uvm_info(get_full_name(), $psprintf("DBG3 fn:process_cmdline_args_snps  io_mstr_seq_cfg %s nativeif %s,useCache:%0d",print(),nativeif,useCache), UVM_LOW);
          end  // } 

    endfunction:process_cmdline_args_snps
    
    function directed_stash_weights();
              if(nativeif =="axi4" || nativeif == "axi5") begin// 
                   rdonce = 1;
                   wrunq  = 1;
              end//}
              if(nativeif == "ace" || nativeif == "ace5") begin//{
                   rdonce = 1;
                   wrunq  = 1;
                   wrlnunq = 1;
                   rdnotshrddty=1;
                   rdshrd=1;
                   rdunq=1;
                   rdcln=1;
              end//}
              else if(nativeif == "acelite" || nativeif == "acelite-e") begin//{
                   wrunqptlstsh    = 1;
                   wrunqfullstsh   = 1;
                   stshonceshrd    = 0;
                   stshonceunq     = 0;
                   stshtrans       = 0;
                   rdonce = 0;
                   wrunq  = 0;
                   wrlnunq = 0;
                   rdnotshrddty=0;
                   rdshrd=0;
                   rdunq=0;
                   rdcln=0;
              end//}
    endfunction

    function new(string name = "io_mstr_seq_cfg");
        super.new(name);
    endfunction:new

    virtual function void init_master_info(string nativeif_i, string instname_i, int funitid_i,bit useCache_i=0,string orderedWriteObservation_i="false",int seq_id_i=0);
        string core_str_tmp, core_str;
        super.init_master_info(nativeif_i, instname_i, funitid_i,useCache_i,orderedWriteObservation_i);
        core_str_tmp  = instname.substr(instname.len()-3, instname.len()-1); 
        if (core_str_tmp inside {"_c0", "_c1", "_c2", "_c3"}) begin 
            core_str = core_str_tmp.substr(core_str_tmp.len()-1, core_str_tmp.len()-1);
            core_id = core_str.atoi();
        end else begin 
            core_id = -1;
        end
        foreach(addrMgrConst::io_subsys_funitid_a[i]) begin
            if(funitid==addrMgrConst::io_subsys_funitid_a[i]) 
                ioaiu_idx = i;
        end
        atomic_transactions_enable = addrMgrConst::io_subsys_atomic_enable_a[ioaiu_idx];
        process_cmdline_args();
    endfunction: init_master_info
endclass
