//-------------------------------------------------------------------------------------------------- 
// APB transaction packet (AR)
//-------------------------------------------------------------------------------------------------- 
class apb_pkt_t extends uvm_sequence_item;
   rand apb_paddr_t     paddr;
   rand apb_pwrite_t    pwrite;
   rand apb_psel_t      psel;
   rand apb_penable_t   penable;
   rand apb_prdata_t    prdata;
   rand apb_pwdata_t    pwdata;
   rand apb_pready_t    pready;
   rand apb_pslverr_t   pslverr;
   static apb_paddr_t   unmap_addr = -1;

   `uvm_object_param_utils_begin(apb_pkt_t)
      `uvm_field_int    (paddr, UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int    (pwrite, UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int    (psel, UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int    (penable, UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int    (prdata, UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int    (pwdata, UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int    (pready, UVM_DEFAULT + UVM_NOPRINT)
      `uvm_field_int    (pslverr, UVM_DEFAULT + UVM_NOPRINT)
   `uvm_object_utils_end

    function new(string name = "apb_pkt_t");
        //pkt_type = "APB";
    endfunction : new

    function string sprint_pkt();
        sprint_pkt = $sformatf("APB: paddr:0x%0x pwrite:0x%0x psel:0x%0x penable:0x%0x prdata:0x%0x pwdata:0x%0x pready:0x%0x pslverr:0x%0x", paddr, pwrite, psel, penable, prdata, pwdata, pready, pslverr);
    endfunction : sprint_pkt
endclass // apb_pkt_t
