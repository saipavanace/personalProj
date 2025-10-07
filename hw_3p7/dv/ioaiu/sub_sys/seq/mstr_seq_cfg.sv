class mstr_seq_cfg extends uvm_object;
    `uvm_object_utils(mstr_seq_cfg);

    string nativeif;
    string instname;
    string orderedWriteObservation;
    int    funitid;
    int ioaiu_idx;
    int seq_id;
    int num_txns;
    bit reduce_addr_area;
    int use_user_addrq=-1;
    bit use_user_noncoh_addrq;
    bit en_excl_txn;
    bit useCache;
    bit [<%=obj.AiuInfo[0].wAddr%>-1:0] start_addr,end_addr;
    bit atomic_transactions_enable;
    bit dont_use_cfg_obj_wt_in_mstr_pipelined_seq;
    bit override_num_txns_from_test;

    function new(string name = "mstr_seq_cfg");
        super.new(name);
    endfunction:new
    
    function string print();
      string s = $sformatf("nativeif:%0s instname:%0s funitid:%0d", nativeif, instname, funitid);
      return s;
    endfunction:print
    
    function void process_cmdline_args();
    $value$plusargs("ioaiu_num_trans=%d", num_txns);
      if ($test$plusargs("reduce_addr_area")) reduce_addr_area = 1;
      if ($test$plusargs("en_excl_txn")) en_excl_txn = 1;
      if ($test$plusargs("use_user_noncoh_addrq")) use_user_noncoh_addrq = 1;
      $value$plusargs("use_user_addrq=%0d",use_user_addrq);
    endfunction:process_cmdline_args

    virtual function void init_master_info(string nativeif_i, string instname_i, int funitid_i, bit useCache_i=0, string orderedWriteObservation_i="false",int seq_id_i=0);
       nativeif = nativeif_i;
       instname = instname_i;
       funitid  = funitid_i;
       useCache  = useCache_i;
       seq_id  = seq_id_i;
       orderedWriteObservation  = orderedWriteObservation_i;
    endfunction: init_master_info

endclass: mstr_seq_cfg
