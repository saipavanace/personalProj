class addr_status_item extends uvm_object;

  bit coh_write_flg;
  bit coh_read_flg;
  bit cmo_flg;
  bit atomic_flg;
  int lut_UID;

  int UID_q[$];
  int reuse_count;
  `uvm_object_utils_begin(addr_status_item)
  `uvm_object_utils_end

  function new(string name = "addr_status_item");
    super.new();
  endfunction : new

  function string convert2string();
    string s;
    reuse_count = UID_q.size();
    if(reuse_count==0) begin
      $sformat(s,"DT_UID:%0d: coh_write:%0b coh_read:%0b cmo:%0b atomic:%0b"
                ,lut_UID,coh_write_flg,coh_read_flg,cmo_flg,atomic_flg);
    end
    else begin
      $sformat(s,"DT_UID:%0p: coh_write:%0b coh_read:%0b cmo:%0b atomic:%0b reuse_count:%0d"
                ,UID_q,coh_write_flg,coh_read_flg,cmo_flg,atomic_flg,reuse_count);
    end
    return(s);
  endfunction

  function bit is_pending(bit is_coh_read = 0);
    if(is_coh_read) begin
      return(coh_write_flg || coh_read_flg || cmo_flg || atomic_flg);
    end
    else begin
      return(coh_write_flg || coh_read_flg || cmo_flg);
    end
  endfunction
endclass