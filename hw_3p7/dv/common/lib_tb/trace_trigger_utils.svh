
//
// Trace trigger utils class + typedefs
//
// 1. Each AIU scoreboard will need to instantiate an object of class trace_trigger_utils
// 2. This object has functions that must be called every time a trigger register is written
//    The interface is 32-bit register writes. Can also use struct fields.
//    The trigger register set number must be passed.
// 3. This object has a function gen_expected_traceme() that is to be called by the unit scoreboard. 
//    It generates the expected traceme based on the registers written in step 2 and the native signals passed into the function.

<%
var isChi   = (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-A") || (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-B") || (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-E");
var isIoaiu = (obj.AiuInfo[obj.Id].fnNativeInterface === "AXI4")  || (obj.AiuInfo[obj.Id].fnNativeInterface === "AXI5") || (obj.AiuInfo[obj.Id].fnNativeInterface === "ACE") || (obj.AiuInfo[obj.Id].fnNativeInterface === "ACE-LITE") || (obj.AiuInfo[obj.Id].fnNativeInterface === "ACELITE-E");
const nTraceRegisters = obj.AiuInfo[obj.Id].nTraceRegisters;

if (isIoaiu) {
  var arrayOfInterfaces           =  Array.isArray(interfaces.axiInt);
  var axiParams;
  if ( arrayOfInterfaces ) {
    axiParams = interfaces.axiInt[0].params;
  } else {
    axiParams = interfaces.axiInt.params;
  }
}

var num_user_bits = 0;
if (isChi) {
  num_user_bits = obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC;
}
if (isIoaiu) {
  num_user_bits = axiParams.wAwUser;
}

var native_trace_supported= 0;
if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-B" || obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-E") {
  native_trace_supported= 1;
}
if (isIoaiu) {
  native_trace_supported = axiParams.eTrace ? 1 : 0;
}

var is_opcode_matching_supported = 0;
if (isChi) {
  is_opcode_matching_supported = 1;
}
if (isIoaiu) {
  if((obj.AiuInfo[obj.Id].fnNativeInterface === "AXI4")||(obj.AiuInfo[obj.Id].fnNativeInterface === "AXI5")) {
    is_opcode_matching_supported = 0;
  }
  else { 
    is_opcode_matching_supported = 1;
  }
  var eAtomic = axiParams.eAtomic ? axiParams.eAtomic : 0;
  var eDomain = axiParams.eDomain ? axiParams.eDomain : 0;
}
%>

// nTraceRegisters        = <%=nTraceRegisters%>;
// Aiu version            = <%=obj.AiuInfo[obj.Id].fnNativeInterface%>;
// isChi                  = <%=isChi%>;
// isIoaiu                = <%=isIoaiu%>;
// native_trace_supported = <%=native_trace_supported%>;
// num_user_bits          = <%=num_user_bits%>;
// num_addr_bits          = <%=obj.AiuInfo[obj.Id].wAddr%>;

typedef struct packed {
  bit  [3:0] memattr; // MSB
  bit        ar;
  bit        aw;
  bit  [1:0] Rsvd1;
  bit  [4:0] range; // size
  bit  [6:0] Rsvd0;
  bit  [4:0] hui;
  bit        hut;
  bit        target_type_match_en;
  bit        user_match_en;
  bit        memattr_match_en;
  bit        opcode_match_en;
  bit        addr_match_en;
  bit        native_trace_en; // LSB
} TRIG_TCTRLR_t;

typedef struct packed {
  bit  [43:12] base_addr_43_12;
} TRIG_TBALR_t;

typedef struct packed {
  bit  [23:00] Rsvd1;
  bit  [07:00] base_addr_51_44;
} TRIG_TBAHR_t;

typedef struct packed {
  bit          valid2;
  bit   [14:0] opcode2;
  bit          valid1;
  bit   [14:0] opcode1;
} TRIG_TOPCR0_t;

typedef struct packed {
  bit          valid4;
  bit   [14:0] opcode4;
  bit          valid3;
  bit   [14:0] opcode3;
} TRIG_TOPCR1_t;

typedef struct packed {
  bit  [31:00] user;
} TRIG_TUBR_t;

typedef struct packed {
  bit  [31:00] user_mask;
} TRIG_TUBMR_t;

class trace_trigger_reg_set extends uvm_object;
  int mpCoreId;

  TRIG_TCTRLR_t TCTRLR_reg;
  TRIG_TBALR_t  TBALR_reg;
  TRIG_TBAHR_t  TBAHR_reg;
  bit [51:0]    TBAR_vreg; // combination of TBAHR and TBALR registers, just for this class
  TRIG_TOPCR0_t TOPCR0_reg;
  TRIG_TOPCR1_t TOPCR1_reg;
  TRIG_TUBR_t   TUBR_reg;
  TRIG_TUBMR_t  TUBMR_reg;

  bit master_init_enabled;
  bit master_init_traceme;
  bit ncore_init_enabled;
  bit ncore_init_traceme;

  bit addr_matched;
  bit memattr_matched;
  bit opcode_matched;
  bit target_type_matched;
  bit user_matched;

  bit fcov_set_traceme;

  function new(string name = "trace_trigger_set");
    TCTRLR_reg.native_trace_en = 1; // master initiated trace is the default
  endfunction : new

  function bit gen_expected_traceme_per_set(
    // Usage: Pass the information from native interface.
    // If there are multiple sets of trigger registers (see parameter nTraceRegisters), call this function multiple times and OR the results.
    // Note: that before calling this function, TCTRLR_write_reg() probably should have been called to set the TCTRLR register bits.
    bit         native_trig_traceme, 
    bit [51:00] native_trig_addr,     // addr bits [11:0] will be ignored
    bit         native_trig_ar,       // should be 0 for CHI
    bit         native_trig_aw,       // should be 0 for CHI
    bit         native_trig_dii_hit, 
    bit         native_trig_dmi_hit, 
    bit   [4:0] native_trig_hui, 
    bit   [3:0] native_trig_memattr,
    bit  [14:0] native_trig_opcode, 
    bit  [31:0] native_trig_user,
    bit         is_chi,
    bit         is_dvm
  );

  master_init_traceme = 0;
  master_init_enabled = 0;
  ncore_init_traceme = 0;
  ncore_init_enabled = 0;

  addr_matched = 0;
  memattr_matched = 0;
  opcode_matched = 0;
  target_type_matched = 0;
  user_matched = 0;

  fcov_set_traceme = 0;

  gen_expected_traceme_per_set = 0; // default unless master_init_enabled or ncore_init_enabled

  master_init_enabled = TCTRLR_reg.native_trace_en;
  ncore_init_enabled = // ncore_initiated mode with at least one match enabled
      TCTRLR_reg.addr_match_en 
   || TCTRLR_reg.memattr_match_en 
   || TCTRLR_reg.opcode_match_en 
   || TCTRLR_reg.target_type_match_en
   || TCTRLR_reg.user_match_en;
  if (master_init_enabled) begin
    master_init_traceme = native_trig_traceme; 
    `uvm_info(get_name(), $psprintf("core%0d: master_init_traceme = %0b", this.mpCoreId, master_init_traceme), UVM_HIGH)
  end
  if (ncore_init_enabled) begin : ncore_init_code
      if (TCTRLR_reg.addr_match_en) begin : addr_matching
        bit [51:00] addr_bits_excluded;
        bit [51:00] addr_range_bottom;
        bit [51:00] addr_range_top;
        bit [51:00] addr_range_size_minus_1;
        addr_range_size_minus_1= 2**(12 + TCTRLR_reg.range)-1;
        addr_range_bottom[51:00] = TBAR_vreg[51:00];
        addr_range_top[51:00]    = TBAR_vreg[51:00] + addr_range_size_minus_1;
        addr_matched = (native_trig_addr[51:00] >= addr_range_bottom[51:00]) && (native_trig_addr[51:00] <= addr_range_top[51:00]);
        `uvm_info(get_name(), $psprintf("core%0d: addr_matched            = %0b",  this.mpCoreId, addr_matched), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: native_trig_addr        = %13h", this.mpCoreId, native_trig_addr), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: addr_range_bottom       = %13h", this.mpCoreId, addr_range_bottom), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: addr_range_top          = %13h", this.mpCoreId, addr_range_top), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: addr_range_size_minus_1 = %13h", this.mpCoreId, addr_range_size_minus_1), UVM_HIGH)
      end : addr_matching
      if (TCTRLR_reg.memattr_match_en) begin : memattr_matching
        // if TCTRLR_reg.aw and TCTRLR_reg.ar are both 0, for example for chi_aiu, then native_trig_aw and native_trig_ar are ignored and only memattr bits are compared
        if (is_chi) begin
          memattr_matched = (native_trig_memattr == TCTRLR_reg.memattr);
        end else begin
          memattr_matched = 
              (native_trig_memattr == TCTRLR_reg.memattr)
           && ((native_trig_aw && TCTRLR_reg.aw) || (native_trig_ar && TCTRLR_reg.ar));
        end
        `uvm_info(get_name(), $psprintf("core%0d: memattr_matched= %0b", this.mpCoreId, memattr_matched), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: is_chi = %0b, native_trig_memattr = %0h, native_trig_aw = %0b, native_trig_ar = %0b", this.mpCoreId, is_chi, native_trig_memattr, native_trig_aw, native_trig_ar), UVM_HIGH)
      end : memattr_matching
      if (TCTRLR_reg.opcode_match_en) begin : opcode_matching
        opcode_matched = 
             ( TOPCR0_reg.valid1 && (native_trig_opcode == TOPCR0_reg.opcode1))
          || ( TOPCR0_reg.valid2 && (native_trig_opcode == TOPCR0_reg.opcode2))
          || ( TOPCR1_reg.valid3 && (native_trig_opcode == TOPCR1_reg.opcode3))
          || ( TOPCR1_reg.valid4 && (native_trig_opcode == TOPCR1_reg.opcode4));
        `uvm_info(get_name(), $psprintf("core%0d: opcode_matched = %0b", this.mpCoreId, opcode_matched), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: native_trig_opcode = %h, TOPCR0_reg = %p, TOPCR1_reg = %p", this.mpCoreId, native_trig_opcode, TOPCR0_reg, TOPCR1_reg), UVM_HIGH)
      end : opcode_matching
      if (TCTRLR_reg.target_type_match_en) begin : target_type_matching
        // FIXME: billc: 2021-08-04, what if dmi_hit and dii_hit are both set, should I report an error?
        // hut=0 for dmi, hut=1 for dii, from Ncore SysArch spec
        target_type_matched = 
              ((native_trig_dii_hit && (TCTRLR_reg.hut==1)) || (native_trig_dmi_hit && (TCTRLR_reg.hut==0)))
           && (native_trig_hui == TCTRLR_reg.hui) && !is_dvm;
        // match iff native user filtered by mask == expected user filtered by mask
        // if user_mask is 0, there is nothing to match against, so user_matched will be set to 0
        // fixme: billc: 2021-08-18, do we need to only look at the actual number of user bits as specified by the parameter? chi scoreboard zeros out non-existent user bits
        // fixme: billc: what about non-zero number of user bits but TUBMR is set to 0
        `uvm_info(get_name(), $psprintf("core%0d: target_type_matched= %0b", this.mpCoreId, target_type_matched), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: TCTRLR_reg.hut = %0b", this.mpCoreId, TCTRLR_reg.hut), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: native_trig_dii_hit = %0b", this.mpCoreId, native_trig_dii_hit), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: native_trig_dmi_hit = %0b", this.mpCoreId, native_trig_dmi_hit), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: native_trig_hui = %h, TCTRLR_reg.hui = %h", this.mpCoreId, native_trig_hui, TCTRLR_reg.hui), UVM_HIGH)
      end: target_type_matching
      if (TCTRLR_reg.user_match_en) begin : user_matching
        user_matched = (TUBMR_reg.user_mask !=0) && ((native_trig_user & TUBMR_reg.user_mask) == (TUBR_reg.user & TUBMR_reg.user_mask));
        `uvm_info(get_name(), $psprintf("core%0d: user_matched= %0b", this.mpCoreId, user_matched), UVM_HIGH)
        `uvm_info(get_name(), $psprintf("core%0d: native_trig_user = %h, TUBMR_reg = %p, TUBR_reg = %p", this.mpCoreId, native_trig_user, TUBMR_reg, TUBR_reg), UVM_HIGH)
      end: user_matching
      ncore_init_traceme = (
        // each one must be disabled or a match
           ( !TCTRLR_reg.addr_match_en        || addr_matched)
        && ( !TCTRLR_reg.memattr_match_en     || memattr_matched)
        && ( !TCTRLR_reg.opcode_match_en      || opcode_matched)
        && ( !TCTRLR_reg.target_type_match_en || target_type_matched)
        && ( !TCTRLR_reg.user_match_en        || user_matched)
      );
  end : ncore_init_code
  case ({master_init_enabled,ncore_init_enabled})
    2'b00: gen_expected_traceme_per_set = 0;
    2'b01: gen_expected_traceme_per_set = ncore_init_traceme;
    2'b10: gen_expected_traceme_per_set = master_init_traceme;
    2'b11: gen_expected_traceme_per_set = master_init_traceme & ncore_init_traceme;
  endcase;
  fcov_set_traceme = gen_expected_traceme_per_set;

  return gen_expected_traceme_per_set;

endfunction : gen_expected_traceme_per_set

  virtual function void print_trigger_set_reg_values();
    `uvm_info(get_name(), $psprintf("core%0d: TCTRLR = %8h", this.mpCoreId, TCTRLR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TCTRLR = %p",  this.mpCoreId, TCTRLR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TBAHR  = %8h", this.mpCoreId, TBAHR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TBAHR  = %p",  this.mpCoreId, TBAHR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TBALR  = %8h", this.mpCoreId, TBALR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TBALR  = %p",  this.mpCoreId, TBALR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TBAR   = %16h",this.mpCoreId, TBAR_vreg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TOPCR0 = %8h", this.mpCoreId, TOPCR0_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TOPCR0 = %p",  this.mpCoreId, TOPCR0_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TOPCR1 = %8h", this.mpCoreId, TOPCR1_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TOPCR1 = %p",  this.mpCoreId, TOPCR1_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TUBR   = %8h", this.mpCoreId, TUBR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TUBR   = %p",  this.mpCoreId, TUBR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TUBMR  = %8h", this.mpCoreId, TUBMR_reg), UVM_NONE)
    `uvm_info(get_name(), $psprintf("core%0d: TUBMR  = %p",  this.mpCoreId, TUBMR_reg), UVM_NONE)
  endfunction : print_trigger_set_reg_values

endclass : trace_trigger_reg_set

class trace_trigger_utils extends uvm_object;
  `uvm_object_param_utils(trace_trigger_utils)

  int mpCoreId;

  int expected_traceme_0_count; // number of times expected_traceme is 0
  int expected_traceme_1_count; // number of times expected_traceme is 1

  bit         fcov_native_trig_traceme; 
  bit [51:00] fcov_native_trig_addr;    // addr bits [11:0] will be ignored
<% if (isIoaiu) { %>
  bit         fcov_native_trig_ar;
  bit         fcov_native_trig_aw;
<% } %>
  bit         fcov_native_trig_dii_hit;
  bit         fcov_native_trig_dmi_hit;
  bit   [4:0] fcov_native_trig_hui;
  bit   [3:0] fcov_native_trig_memattr;
<% if (isChi) { %>
  chi_req_opcode_t fcov_native_trig_opcode;
<% } %>
<% if (isIoaiu) { %>
  bit [14:00]      fcov_native_trig_opcode;
<% } %>
  bit  [31:0] fcov_native_trig_user;
  bit [<%=nTraceRegisters%>-1:0] fcov_sets_native_matched; // one bit per register set
  bit [<%=nTraceRegisters%>-1:0] fcov_sets_addr_matched; // one bit per register set
  bit [<%=nTraceRegisters%>-1:0] fcov_sets_memattr_matched; // one bit per register set
<% if (is_opcode_matching_supported) { %>
  bit [<%=nTraceRegisters%>-1:0] fcov_sets_opcode_matched; // one bit per register set
<% } %>
  bit [<%=nTraceRegisters%>-1:0] fcov_sets_target_type_matched; // one bit per register set
<% if (num_user_bits > 0) { %>
  bit [<%=nTraceRegisters%>-1:0] fcov_sets_user_matched; // one bit per register set
<% } %>
  bit [<%=nTraceRegisters%>-1:0] fcov_sets_traceme; // one bit per register set
  bit         fcov_traceme_out;

trace_trigger_reg_set trigger_reg_set[<%=nTraceRegisters%>];

  covergroup cg_trigger;
<% for(let i=0; i<nTraceRegisters; i++) {%>
<% if (native_trace_supported) { %>
    // #Cover.IOAIU.TTRI.TCTRLR.native_trace_en 
    //#Cover.CHIAIU.TTRI.TCTRLR.native_trace_en 
    cp_TCTRLR_<%=i%>_native_trace_en      : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.native_trace_en;
<% } %>
    // #Cover.IOAIU.TTRI.TCTRLR.addr_match_en 
    //#Cover.CHIAIU.TTRI.TCTRLR.addr_match_en 
    cp_TCTRLR_<%=i%>_addr_match_en        : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.addr_match_en;
    // #Cover.IOAIU.TTRI.TCTRLR.memattr_match_en 
    //#Cover.CHIAIU.TTRI.TCTRLR.memattr_match_en 
    cp_TCTRLR_<%=i%>_memattr_match_en     : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.memattr_match_en;
<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.TCTRLR.opcode_match_en 
    //#Cover.CHIAIU.TTRI.TCTRLR.opcode_match_en 
    cp_TCTRLR_<%=i%>_opcode_match_en      : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.opcode_match_en;
<% } %>
    // #Cover.IOAIU.TTRI.TCTRLR.target_type_match_en 
    //#Cover.CHIAIU.TTRI.TCTRLR.target_type_match_en 
    cp_TCTRLR_<%=i%>_target_type_match_en : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.target_type_match_en;
<% if (num_user_bits > 0) { %>
    // #Cover.IOAIU.TTRI.TCTRLR.user_match_en 
    //#Cover.CHIAIU.TTRI.TCTRLR.user_match_en 
    cp_TCTRLR_<%=i%>_user_match_en        : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.user_match_en;
<% } %>

    // #Cover.IOAIU.TTRI_cross.TCTRLR.match_enables
    //#Cover.CHIAIU.TTRI_cross.TCTRLR.match_enables
<% if (native_trace_supported) { %>
    cc_TCTRLR_<%=i%>_native_addr_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_native_trace_en,
                                              cp_TCTRLR_<%=i%>_addr_match_en;
    cc_TCTRLR_<%=i%>_native_mem_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_native_trace_en,
                                              cp_TCTRLR_<%=i%>_memattr_match_en;
  <% if (is_opcode_matching_supported) { %>
    cc_TCTRLR_<%=i%>_native_opcode_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_native_trace_en,
                                              cp_TCTRLR_<%=i%>_opcode_match_en;
  <% } %>
    cc_TCTRLR_<%=i%>_native_targ_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_native_trace_en,
                                              cp_TCTRLR_<%=i%>_target_type_match_en;
  <% if (num_user_bits > 0) { %>
    cc_TCTRLR_<%=i%>_native_user_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_native_trace_en,
                                              cp_TCTRLR_<%=i%>_user_match_en;
  <% } %>
<% } %>

    cc_TCTRLR_<%=i%>_addr_mem_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_addr_match_en,
                                              cp_TCTRLR_<%=i%>_memattr_match_en;
<% if (is_opcode_matching_supported) { %>
    cc_TCTRLR_<%=i%>_addr_opcode_match_en : cross 
                                              cp_TCTRLR_<%=i%>_addr_match_en,
                                              cp_TCTRLR_<%=i%>_opcode_match_en;
<% } %>
    cc_TCTRLR_<%=i%>_addr_targ_match_en   : cross 
                                              cp_TCTRLR_<%=i%>_addr_match_en,
                                              cp_TCTRLR_<%=i%>_target_type_match_en;
<% if (num_user_bits > 0) { %>
    cc_TCTRLR_<%=i%>_addr_user_match_en   : cross 
                                              cp_TCTRLR_<%=i%>_addr_match_en,
                                              cp_TCTRLR_<%=i%>_user_match_en;
<% } %>

<% if (is_opcode_matching_supported) { %>
    cc_TCTRLR_<%=i%>_mem_opcode_match_en  : cross 
                                              cp_TCTRLR_<%=i%>_memattr_match_en,
                                              cp_TCTRLR_<%=i%>_opcode_match_en;
<% } %>
    cc_TCTRLR_<%=i%>_mem_targ_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_memattr_match_en,
                                              cp_TCTRLR_<%=i%>_target_type_match_en;
<% if (num_user_bits > 0) { %>
    cc_TCTRLR_<%=i%>_mem_user_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_memattr_match_en,
                                              cp_TCTRLR_<%=i%>_user_match_en;
<% } %>
<% if (is_opcode_matching_supported) { %>
    cc_TCTRLR_<%=i%>_opcode_targ_match_en : cross 
                                              cp_TCTRLR_<%=i%>_opcode_match_en,
                                              cp_TCTRLR_<%=i%>_target_type_match_en;
  <% if (num_user_bits > 0) { %>
    cc_TCTRLR_<%=i%>_opcode_user_match_en    : cross 
                                              cp_TCTRLR_<%=i%>_opcode_match_en,
                                              cp_TCTRLR_<%=i%>_user_match_en;
  <% } %>
<% } %>
<% if (num_user_bits > 0) { %>
    cc_TCTRLR_<%=i%>_targ_user_match_en   : cross 
                                              cp_TCTRLR_<%=i%>_target_type_match_en,
                                              cp_TCTRLR_<%=i%>_user_match_en;
<% } %>
    // #Cover.IOAIU.TTRI.TCTRLR.range
    //#Cover.CHIAIU.TTRI.TCTRLR.range
    cp_TCTRLR_<%=i%>_range                : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.range;
    // #Cover.IOAIU.TTRI.TCTRLR.memattr
    //#Cover.CHIAIU.TTRI.TCTRLR.memattr
    cp_TCTRLR_<%=i%>_memattr              : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.memattr;
<% if (isIoaiu) { %>
    // #Cover.IOAIU.TTRI.TCTRLR.ar
    cp_TCTRLR_<%=i%>_ar                   : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.ar;
    // #Cover.IOAIU.TTRI.TCTRLR.aw
    cp_TCTRLR_<%=i%>_aw                   : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.aw;
    // #Cover.IOAIU.TTRI_cross.TCTRLR.memattr_fields
    cc_TCTRLR_<%=i%>_ar_aw_memattr_match_en : cross cp_TCTRLR_<%=i%>_ar, cp_TCTRLR_<%=i%>_aw, cp_TCTRLR_<%=i%>_memattr_match_en;
<% } %>
    // #Cover.IOAIU.TTRI.TCTRLR.hut
    //#Cover.CHIAIU.TTRI.TCTRLR.hut
    cp_TCTRLR_<%=i%>_hut                  : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.hut {
                                              bins dmi  = {0};
                                              bins dii  = {1};
                                            }
    // #Cover.IOAIU.TTRI.TCTRLR.hui
    //#Cover.CHIAIU.TTRI.TCTRLR.hui
    cp_TCTRLR_<%=i%>_hui                  : coverpoint trigger_reg_set[<%=i%>].TCTRLR_reg.hui;
    // #Cover.IOAIU.TTRI.TBAHR_TBALR
    //#Cover.CHIAIU.TTRI.TBAHR_TBALR
    cp_TBAR_<%=i%>_addr_51_12             : coverpoint {trigger_reg_set[<%=i%>].TBAHR_reg.base_addr_51_44, trigger_reg_set[<%=i%>].TBALR_reg.base_addr_43_12} {
                                              bins all_0s  = {'h00_0000_0000};
                                              bins range_0_1 = {['h00_0000_0001:'h1f_ffff_ffff]};
                                              bins range_2_3 = {['h20_0000_0000:'h3f_ffff_ffff]};
                                              bins range_4_5 = {['h40_0000_0000:'h5f_ffff_ffff]};
                                              bins range_6_7 = {['h60_0000_0000:'h7f_ffff_ffff]};
                                              bins range_8_9 = {['h80_0000_0000:'h9f_ffff_ffff]};
                                              bins range_a_b = {['ha0_0000_0000:'hbf_ffff_ffff]};
                                              bins range_c_d = {['hc0_0000_0000:'hdf_ffff_ffff]};
                                              bins range_e_f = {['he0_0000_0000:'hff_ffff_ffff]};
                                              bins all_fs  = {'hff_ffff_ffff};
                                              bins others  = default;
                                            } // fixme: need bins for the addr hi/lo crossing?

<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.TOPCR.valid
    //#Cover.CHIAIU.TTRI.TOPCR.valid
    cp_TOPCR_<%=i%>_valid_4_1             : coverpoint {trigger_reg_set[<%=i%>].TOPCR1_reg.valid4, trigger_reg_set[<%=i%>].TOPCR1_reg.valid3, trigger_reg_set[<%=i%>].TOPCR0_reg.valid2, trigger_reg_set[<%=i%>].TOPCR0_reg.valid1};
<% } %>

    // tried iff (trigger_reg_set[<%=i%>].TOPCR1_reg.valid4) but it caused a large drop in coverage
<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.TOPCR1.opcode4
    //#Cover.CHIAIU.TTRI.TOPCR1.opcode4
    cp_TOPCR1_<%=i%>_opcode4              : coverpoint trigger_reg_set[<%=i%>].TOPCR1_reg.opcode4 {
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-B" || obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-E") { %>
                                              bins upto_3f[] = {[0:'h3f]}; // CHI-B opcode width is currently 6 bits
                                              bins too_high  = default;
<% } %>
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-A") { %>
                                              bins upto_1f[] = {[0:'h1f]}; // CHI-A opcode width is currently 5 bits
                                              bins too_high  = default;
<% } %>
<% if (isIoaiu) { %>
                                              bins upto_3f[] = {[0:'h3f]};
                                              bins above_3f  = {['h3f:$]}; // FIXME: need to understand this better
<% } %>
                                            }
<% } %>

    // tried iff (trigger_reg_set[<%=i%>].TOPCR1_reg.valid3) but it caused a large drop in coverage
<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.TOPCR1.opcode3
    //#Cover.CHIAIU.TTRI.TOPCR1.opcode3
    cp_TOPCR1_<%=i%>_opcode3              : coverpoint trigger_reg_set[<%=i%>].TOPCR1_reg.opcode3 {
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-B" || obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-E") { %>
                                              bins upto_3f[] = {[0:'h3f]}; // CHI-B opcode width is currently 6 bits
                                              bins too_high  = default;
<% } %>
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-A") { %>
                                              bins upto_1f[] = {[0:'h1f]}; // CHI-A opcode width is currently 5 bits
                                              bins too_high  = default;
<% } %>
<% if (isIoaiu) { %>
                                              bins upto_3f[] = {[0:'h3f]};
                                              bins above_3f  = {['h3f:$]}; // FIXME: need to understand this better
<% } %>
                                            }
<% } %>

    // tried iff (trigger_reg_set[<%=i%>].TOPCR0_reg.valid2) but it caused a large drop in coverage
<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.TOPCR0.opcode2
    //#Cover.CHIAIU.TTRI.TOPCR0.opcode2
    cp_TOPCR0_<%=i%>_opcode2              : coverpoint trigger_reg_set[<%=i%>].TOPCR0_reg.opcode2 {
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-B" || obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-E") { %>
                                              bins upto_3f[] = {[0:'h3f]}; // CHI-B opcode width is currently 6 bits
                                              bins too_high  = default;
<% } %>
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-A") { %>
                                              bins upto_1f[] = {[0:'h1f]}; // CHI-A opcode width is currently 5 bits
                                              bins too_high  = default;
<% } %>
<% if (isIoaiu) { %>
                                              bins upto_3f[] = {[0:'h3f]};
                                              bins above_3f  = {['h3f:$]}; // FIXME: need to understand this better
<% } %>
                                            }
<% } %>

    // tried iff (trigger_reg_set[<%=i%>].TOPCR0_reg.valid21 but it caused a large drop in coverage
<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.TOPCR0.opcode1
    //#Cover.CHIAIU.TTRI.TOPCR0.opcode1
    cp_TOPCR0_<%=i%>_opcode1              : coverpoint trigger_reg_set[<%=i%>].TOPCR0_reg.opcode1 {
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-B" || obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-E") { %>
                                              bins upto_3f[] = {[0:'h3f]}; // CHI-B opcode width is currently 6 bits
                                              bins too_high  = default;
<% } %>
<% if (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-A") { %>
                                              bins upto_1f[] = {[0:'h1f]}; // CHI-A opcode width is currently 5 bits
                                              bins too_high  = default;
<% } %>
<% if (isIoaiu) { %>
                                              bins upto_3f[] = {[0:'h3f]};
                                              bins above_3f  = {['h3f:$]}; // FIXME: need to understand this better
<% } %>
                                            }
<% } %>

<% if (num_user_bits > 0) { %>
    // #Cover.IOAIU.TTRI.TUBMR.user_mask
    //#Cover.CHIAIU.TTRI.TUBMR.user_mask
    cp_TUBMR_<%=i%>_user_mask             : coverpoint trigger_reg_set[<%=i%>].TUBMR_reg.user_mask {
                                              bins ge_1_bits[] = {['h0000_0000:'h0000_0001]};
<% if (num_user_bits > 2) { %>
                                              bins ge_2_bits[] = {['h0000_0002:'h0000_0003]};
<% } %>
<% if (num_user_bits > 3) { %>
                                              bins ge_3_bits[] = {['h0000_0004:'h0000_0007]};
<% } %>
<% if (num_user_bits > 4) { %>
                                              bins ge_4_bits[] = {['h0000_0008:'h0000_000f]};
<% } %>
<% if (num_user_bits > 32) { %>
                                              bins ge_5_bits   = {['h0000_0010:'hffff_fffe]};
                                              bins all_fs  = {'hffff_ffff};
<% } %>
                                              bins others  = default;
                                            }
<%  }  %>

<% if (num_user_bits > 0) { %>
    // cover TUBR masked by TUBMR, not just TUBR alone
    // #Cover.IOAIU.TTRI.TUBR_masked_by_TUBMR
    //#Cover.CHIAIU.TTRI.TUBR_masked_by_TUBMR
    cp_TUBR_<%=i%>_masked_user            : coverpoint (trigger_reg_set[<%=i%>].TUBR_reg.user & trigger_reg_set[<%=i%>].TUBMR_reg.user_mask)  {
                                              bins ge_1_bits[] = {['h0000_0000:'h0000_0001]};
<% if (num_user_bits > 2) { %>
                                              bins ge_2_bits[] = {['h0000_0002:'h0000_0003]};
<% } %>
<% if (num_user_bits > 3) { %>
                                              bins ge_3_bits[] = {['h0000_0004:'h0000_0007]};
<% } %>
<% if (num_user_bits > 4) { %>
                                              bins ge_4_bits[] = {['h0000_0008:'h0000_000f]};
<% } %>
<% if (num_user_bits > 32) { %>
                                              bins ge_5_bits   = {['h0000_0010:'hffff_fffe]};
                                              bins all_fs  = {'hffff_ffff};
<% } %>
                                              bins others  = default;
                                            }
<%  }  %>

    // below are coverpoints for intermediate and output trigger_utils variables
<% if (native_trace_supported) { %>
    cp_master_init_enabled_<%=i%>         : coverpoint trigger_reg_set[<%=i%>].master_init_enabled;
    // #Cover.IOAIU.TTRI.native_matched
    //#Cover.CHIAIU.TTRI.native_matched
    //#Cover.IOAIU.Native.Match
    cp_master_init_traceme_<%=i%>         : coverpoint trigger_reg_set[<%=i%>].master_init_traceme iff (trigger_reg_set[<%=i%>].master_init_enabled) {
                                              bins native_traceme     = {1};
                                              bins native_not_traceme = {0};
                                            }
<% } %>
    cp_ncore_init_enabled_<%=i%>          : coverpoint trigger_reg_set[<%=i%>].ncore_init_enabled;
    cp_ncore_init_traceme_<%=i%>          : coverpoint trigger_reg_set[<%=i%>].ncore_init_traceme iff (trigger_reg_set[<%=i%>].ncore_init_enabled);
    // #Cover.IOAIU.TTRI.addr_matched
    //#Cover.CHIAIU.TTRI.addr_matched
    //#Cover.IOAIU.Addr.Match
    cp_addr_matched_<%=i%>                : coverpoint trigger_reg_set[<%=i%>].addr_matched iff (trigger_reg_set[<%=i%>].TCTRLR_reg.addr_match_en) {
                                              bins addr_matched     = {1};
                                              bins addr_not_matched = {0};
                                            }
    //#Cover.IOAIU.TTRI.memattr_matched
    //#Cover.CHIAIU.TTRI.memattr_matched
    //#Cover.IOAIU.Memattr.Match
    cp_memattr_matched_<%=i%>             : coverpoint trigger_reg_set[<%=i%>].memattr_matched iff (trigger_reg_set[<%=i%>].TCTRLR_reg.memattr_match_en) {
                                              bins memattr_matched     = {1};
                                              bins memattr_not_matched = {0};
                                            }
<% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
`ifndef VCS
<% if (isIoaiu) { %>
    cc_native_ar_memattr_matched_<%=i%>   : cross cp_native_trig_ar, cp_memattr_matched_<%=i%> {
                                              ignore_bins ar_0  = binsof (cp_native_trig_ar) intersect {0}; // ignore when ar=0, cover when ar=1
    }
    cc_native_aw_memattr_matched_<%=i%>   : cross cp_native_trig_aw, cp_memattr_matched_<%=i%> {
                                              ignore_bins aw_0  = binsof (cp_native_trig_aw) intersect {0}; // ignore when aw=0, cover when aw=1
    }
<% } %>
`endif // `ifndef VCS
<% } else {%>
<% if (isIoaiu) { %>
    cc_native_ar_memattr_matched_<%=i%>   : cross cp_native_trig_ar, cp_memattr_matched_<%=i%> {
                                              ignore_bins ar_0  = binsof (cp_native_trig_ar) intersect {0}; // ignore when ar=0, cover when ar=1
    }
    cc_native_aw_memattr_matched_<%=i%>   : cross cp_native_trig_aw, cp_memattr_matched_<%=i%> {
                                              ignore_bins aw_0  = binsof (cp_native_trig_aw) intersect {0}; // ignore when aw=0, cover when aw=1
    }
<% } %>
<% } %>
<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.opcode_matched
    //#Cover.CHIAIU.TTRI.opcode_matched
    //#Cover.IOAIU.Opcode.Match
    cp_opcode_matched_<%=i%>              : coverpoint trigger_reg_set[<%=i%>].opcode_matched iff (trigger_reg_set[<%=i%>].TCTRLR_reg.opcode_match_en) {
                                              bins opcode_matched     = {1};
                                              bins opcode_not_matched = {0};
                                            }
<% } %>
    // #Cover.IOAIU.TTRI.target_type_matched
    //#Cover.CHIAIU.TTRI.target_type_matched
    //#Cover.IOAIU.TargetType.Match
    cp_target_type_matched_<%=i%>         : coverpoint trigger_reg_set[<%=i%>].target_type_matched iff (trigger_reg_set[<%=i%>].TCTRLR_reg.target_type_match_en) {
                                              bins target_type_matched     = {1};
                                              bins target_type_not_matched = {0};
                                            }
<% if (num_user_bits > 0) { %>
    // #Cover.IOAIU.TTRI.user_matched
    //#Cover.CHIAIU.TTRI.user_matched
    //#Cover.IOAIU.User.Match
    cp_user_matched_<%=i%>                : coverpoint trigger_reg_set[<%=i%>].user_matched iff (trigger_reg_set[<%=i%>].TCTRLR_reg.user_match_en) {
                                              bins user_matched     = {1};
                                              bins user_not_matched = {0};
                                            }
<% } %>
// note: below is an attempt to cross each pair of the following
// native_traceme or master_init_traceme (conditional existence per config)
// user_matched (conditional existence per config)
// target_type_matched
// opcode_matched
// memattr_matched
// addr_matched
// because this of the conditional existence, I split it across multiple cross statements

    // #Cover.IOAIU.TTRI_cross.matches
    //#Cover.CHIAIU.TTRI_cross.matches
    //#Cover.IOAIU.All.Match
<% if (native_trace_supported) { %>
    cc_matched_native_addr_<%=i%>         : cross 
                                              cp_master_init_traceme_<%=i%>,
                                              cp_addr_matched_<%=i%>;
    cc_matched_native_mem_<%=i%>          : cross 
                                              cp_master_init_traceme_<%=i%>,
                                              cp_memattr_matched_<%=i%>;
  <% if (is_opcode_matching_supported) { %>
    cc_matched_native_opcode_<%=i%>       : cross 
                                              cp_master_init_traceme_<%=i%>,
                                              cp_opcode_matched_<%=i%>;
  <% } %>
    cc_matched_native_targ_<%=i%>         : cross 
                                              cp_master_init_traceme_<%=i%>,
                                              cp_target_type_matched_<%=i%>;
  <% if (num_user_bits > 0) { %>
    cc_matched_native_user_<%=i%>           : cross 
                                              cp_master_init_traceme_<%=i%>,
                                              cp_user_matched_<%=i%>;
  <% } %>
<% } %>
    cc_matched_addr_mem_<%=i%>            : cross 
                                              cp_addr_matched_<%=i%>,
                                              cp_memattr_matched_<%=i%>;
<% if (is_opcode_matching_supported) { %>
    cc_matched_addr_opcode_<%=i%>         : cross 
                                              cp_addr_matched_<%=i%>,
                                              cp_opcode_matched_<%=i%>;
<% } %>
    cc_matched_addr_targ_<%=i%>           : cross 
                                              cp_addr_matched_<%=i%>,
                                              cp_target_type_matched_<%=i%>;
<% if (num_user_bits > 0) { %>
    cc_matched_addr_user_<%=i%>           : cross 
                                              cp_addr_matched_<%=i%>,
                                              cp_user_matched_<%=i%>;
<% } %>
<% if (is_opcode_matching_supported) { %>
    cc_matched_mem_opcode_<%=i%>         : cross 
                                              cp_memattr_matched_<%=i%>,
                                              cp_opcode_matched_<%=i%>;
<% } %>
    cc_matched_mem_targ_<%=i%>           : cross 
                                              cp_memattr_matched_<%=i%>,
                                              cp_target_type_matched_<%=i%>;
<% if (num_user_bits > 0) { %>
    cc_matched_mem_user_<%=i%>           : cross 
                                              cp_memattr_matched_<%=i%>,
                                              cp_user_matched_<%=i%>;
<% } %>
<% if (is_opcode_matching_supported) { %>
    cc_matched_opcode_targ_<%=i%>        : cross 
                                              cp_opcode_matched_<%=i%>,
                                              cp_target_type_matched_<%=i%>;
<% } %>
<% if (is_opcode_matching_supported) { %>
<% if (num_user_bits > 0) { %>
    cc_matched_opcode_user_<%=i%>        : cross 
                                              cp_opcode_matched_<%=i%>,
                                              cp_user_matched_<%=i%>;
<% } %>
<% } %>
<% if (num_user_bits > 0) { %>
    cc_matched_targ_user_<%=i%>          : cross 
                                              cp_target_type_matched_<%=i%>,
                                              cp_user_matched_<%=i%>;
<% } %>

    cp_set_traceme_<%=i%>                 : coverpoint trigger_reg_set[<%=i%>].fcov_set_traceme;
<%}%>
    // #Cover.IOAIU.TTRI.traceme_out_expected_per_set
    //#Cover.CHIAIU.TTRI.traceme_out_expected_per_set
    cp_sets_traceme                       : coverpoint fcov_sets_traceme; // one bit per register set
// note: for most sets matched coverpoints, bins are limited because of cost of hitting all combinations
    // #Cover.IOAIU.TTRI_cross.native_matched_per_set
    //#Cover.CHIAIU.TTRI_cross.native_matched_per_set
    cp_sets_native_matched                  : coverpoint fcov_sets_native_matched { // one bit per register set
<% if (nTraceRegisters>=4) {%>
                                              bins val_8  = {8}; // one-hot
<% } %>
<% if (nTraceRegisters>=3) {%>
                                              bins val_4  = {4}; // one-hot
<% } %>
<% if (nTraceRegisters>=2) {%>
                                              bins val_2  = {2}; // one-hot
<% } %>
                                              bins val_1  = {1}; // one-hot
                                              bins val_0  = {0}; 
                                            }
    // #Cover.IOAIU.TTRI_cross.addr_matched_per_set
    //#Cover.CHIAIU.TTRI_cross.addr_matched_per_set
    cp_sets_addr_matched                  : coverpoint fcov_sets_addr_matched { // one bit per register set
<% if (nTraceRegisters>=4) {%>
                                              bins val_8  = {8}; // one-hot
<% } %>
<% if (nTraceRegisters>=3) {%>
                                              bins val_4  = {4}; // one-hot
<% } %>
<% if (nTraceRegisters>=2) {%>
                                              bins val_2  = {2}; // one-hot
<% } %>
                                              bins val_1  = {1}; // one-hot
                                              bins val_0  = {0}; 
                                            }
    // #Cover.IOAIU.TTRI_cross.memattr_matched_per_set
    //#Cover.CHIAIU.TTRI_cross.memattr_matched_per_set
    cp_sets_memattr_matched               : coverpoint fcov_sets_memattr_matched { // one bit per register set
<% if (nTraceRegisters>=4) {%>
                                              bins val_8  = {8}; // one-hot
<% } %>
<% if (nTraceRegisters>=3) {%>
                                              bins val_4  = {4}; // one-hot
<% } %>
<% if (nTraceRegisters>=2) {%>
                                              bins val_3  = {3}; // 1:0 pair
                                              bins val_2  = {2}; // one-hot
<% } %>
                                              bins val_1  = {1}; // one-hot
                                              bins val_0  = {0}; 
                                            }
<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI_cross.opcode_matched_per_set
    //#Cover.CHIAIU.TTRI_cross.opcode_matched_per_set
    cp_sets_opcode_matched                : coverpoint fcov_sets_opcode_matched { // one bit per register set
<% if (nTraceRegisters>=4) {%>
                                              bins val_8  = {8}; // one-hot
<% } %>
<% if (nTraceRegisters>=3) {%>
                                              bins val_4  = {4}; // one-hot
<% } %>
<% if (nTraceRegisters>=2) {%>
                                              bins val_3  = {3}; // 1:0 pair
                                              bins val_2  = {2}; // one-hot
<% } %>
                                              bins val_1  = {1}; // one-hot
                                              bins val_0  = {0}; 
                                            }
<% } %>
    // #Cover.IOAIU.TTRI_cross.target_type_matched_per_set
    //#Cover.CHIAIU.TTRI_cross.target_type_matched_per_set
    cp_sets_target_type_matched           : coverpoint fcov_sets_target_type_matched { // one bit per register set
<% if (nTraceRegisters>=4) {%>
                                              bins val_8  = {8}; // one-hot
<% } %>
<% if (nTraceRegisters>=3) {%>
                                              bins val_6  = {6}; // 2:1 pair
                                              bins val_5  = {5}; // 2:0 pair
                                              bins val_4  = {4}; // one-hot
<% } %>
<% if (nTraceRegisters>=2) {%>
                                              bins val_3  = {3}; // 1:0 pair
                                              bins val_2  = {2}; // one-hot
<% } %>
                                              bins val_1  = {1}; // one-hot
                                              bins val_0  = {0}; 
                                            }
<% if (num_user_bits > 0) { %>
    // #Cover.IOAIU.TTRI_cross.user_matched_per_set
    //#Cover.CHIAIU.TTRI_cross.user_matched_per_set
    cp_sets_user_matched                  : coverpoint fcov_sets_user_matched; // one bit per register set
<% } %>

<% if (native_trace_supported) { %>
    // #Cover.IOAIU.TTRI.native_traceme
    //#Cover.CHIAIU.TTRI.native_traceme
    cp_native_trig_traceme                : coverpoint fcov_native_trig_traceme;
<% } %>
// cover upper native_trig_addr bits
// bits 51:44 relate to TBAHR 
    // #Cover.IOAIU.TTRI.native_addr
    //#Cover.CHIAIU.TTRI.native_addr
<% for(let a=obj.AiuInfo[obj.Id].wAddr; a>=45; a--) {%>
    cp_native_trig_addr_<%=a-1%>          : coverpoint fcov_native_trig_addr[<%=a-1%>];
<%}%>
// bits 43:12 relate to TBALR
<% if (obj.AiuInfo[obj.Id].wAddr>=44) {%>
    cp_native_trig_addr_43                : coverpoint fcov_native_trig_addr[43];
<%}%>
<% if (obj.AiuInfo[obj.Id].wAddr>=32) {%>
    cp_native_trig_addr_31                : coverpoint fcov_native_trig_addr[31];
<%}%>
    cp_native_trig_addr_12                : coverpoint fcov_native_trig_addr[12];
    // #Cover.IOAIU.TTRI.native_memattr
    //#Cover.CHIAIU.TTRI.native_memattr
    cp_native_trig_memattr                : coverpoint fcov_native_trig_memattr { // fixme: decide whether to qualify with memattr_match_ens?
<% if (isChi) { %>
                                              bins values_0_to_5[]         = {[0:5]};
                                              bins value_d                 = {'hd};
                                              ignore_bins value_c          = {'hc}; // FIXME: is this illegal?
                                              bins others  = default;
<% } %>
<% if (isIoaiu) { %>
                                              // looked at AMBA spec for legal AxCACHE values
                                              bins        values_0_to_3[]  = {[0:3]};
                                              ignore_bins values_4_to_5[]  = {[4:5]};
                                              bins        values_6_to_7[]  = {[6:7]};
                                              ignore_bins values_8_to_9[]  = {[8:9]};
                                              bins        values_a_to_b[]  = {['ha:'hb]};
                                              ignore_bins values_c_to_d[]  = {['hc:'hd]};
                                              bins        values_e_to_f[]  = {['he:'hf]};
                                              illegal_bins others          = default;
<% } %>
    }
<% if (isIoaiu) { %>
    // #Cover.IOAIU.TTRI.native_ar
    cp_native_trig_ar                     : coverpoint fcov_native_trig_ar;
    // #Cover.IOAIU.TTRI.native_aw
    cp_native_trig_aw                     : coverpoint fcov_native_trig_aw;
    // #Cover.IOAIU.TTRI_cross.native.memattr_fields
    cc_native_trig_ar_memattr             : cross cp_native_trig_ar, cp_native_trig_memattr {
                                              ignore_bins ar_0  = binsof (cp_native_trig_ar) intersect {0}; // ignore when ar=0, cover when ar=1
                                            }
    cc_native_trig_aw_memattr             : cross cp_native_trig_aw, cp_native_trig_memattr {
                                              ignore_bins aw_0  = binsof (cp_native_trig_aw) intersect {0}; // ignore when aw=0, cover when aw=1
                                            }
<% if(obj.testBench == 'fsys') { %>
`ifdef VCS
<% for(let i=0; i<nTraceRegisters; i++) {%>
    cc_native_ar_memattr_matched_<%=i%>   : cross cp_native_trig_ar, cp_memattr_matched_<%=i%> {
                                              ignore_bins ar_0  = binsof (cp_native_trig_ar) intersect {0}; // ignore when ar=0, cover when ar=1
    }
    cc_native_aw_memattr_matched_<%=i%>   : cross cp_native_trig_aw, cp_memattr_matched_<%=i%> {
                                              ignore_bins aw_0  = binsof (cp_native_trig_aw) intersect {0}; // ignore when aw=0, cover when aw=1
    }
<%}%>
`endif // `ifdef VCS
<% } %>
<% } %>

<% if (is_opcode_matching_supported) { %>
    // #Cover.IOAIU.TTRI.native_opcode
    //#Cover.CHIAIU.TTRI.native_opcode
<% if (isChi) { %>
    cp_native_trig_opcode                 : coverpoint fcov_native_trig_opcode {
                                              illegal_bins bin_0x06        = {'h06};
                                              illegal_bins UNSUP_OPCODE_1  = {UNSUP_OPCODE_1};
                                              illegal_bins UNSUP_OPCODE_2  = {UNSUP_OPCODE_2};
                                              illegal_bins UNSUP_OPCODE_3  = {UNSUP_OPCODE_3};
                                              <% if(obj.AiuInfo[obj.Id].fnNativeInterface != "CHI-E") { %>
                                              illegal_bins UNSUP_OPCODE_4  = {UNSUP_OPCODE_4};
                                              <%}%>
                                              illegal_bins UNSUP_OPCODE_6  = {UNSUP_OPCODE_6};
<% } %>
<% if (isChi && (obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-B" || obj.AiuInfo[obj.Id].fnNativeInterface === "CHI-E")) { %>
                                              illegal_bins UNSUP_OPCODE_7  = {UNSUP_OPCODE_7};
                                              illegal_bins UNSUP_OPCODE_8  = {UNSUP_OPCODE_8};
                                              illegal_bins UNSUP_OPCODE_9  = {UNSUP_OPCODE_9};
                                              illegal_bins UNSUP_OPCODE_10 = {UNSUP_OPCODE_10};
                                              illegal_bins UNSUP_OPCODE_11 = {UNSUP_OPCODE_11};
<% } %>
<% if (isChi) { %>
    }
<% } %>
<% if ((isIoaiu) && (eAtomic)) { %>
    cp_native_trig_opcode_AwAtop          : coverpoint fcov_native_trig_opcode[6];
<% for(let i=0; i<nTraceRegisters; i++) {%>
    cc_native_trig_opcode_AwAtop_matched_<%=i%> : cross cp_opcode_matched_<%=i%>, cp_native_trig_opcode_AwAtop {
                                                   ignore_bins matched_0  = binsof (cp_opcode_matched_<%=i%>) intersect {0}; // ignore when no match
                                                 }
<% } %>
<% } %>
<% if ((isIoaiu) && (eDomain)) { %>
    cp_native_trig_opcode_domain          : coverpoint fcov_native_trig_opcode[5:4];
    // #Cover.IOAIU.TTRI_cross.native.opcode_fields
<% for(let i=0; i<nTraceRegisters; i++) {%>
    cc_native_trig_opcode_domain_matched_<%=i%> : cross cp_opcode_matched_<%=i%>, cp_native_trig_opcode_domain {
                                                   ignore_bins matched_0  = binsof (cp_opcode_matched_<%=i%>) intersect {0}; // ignore when no match
                                                 }
<% } %>
<% } %>
<% if ((isIoaiu) && (eDomain)) { %>
    // compare bins to AMBA spec ARSNOOP and AWSNOOP values
    cp_native_trig_opcode_snoop           : coverpoint fcov_native_trig_opcode[3:0] {
                                      <%if (obj.fnNativeInterface == "ACE") { %>
                                              bins values_legal_0_to_5[]    = {[0:5]};  
                                              ignore_bins ignore_6          = {6};
                                              bins values_legal_7_to_9[]    = {[7:9]};  
                                              ignore_bins ignore_a          = {'ha};
                                              bins values_legal_b_to_d[]    = {['hb:'hd]};  
                                              ignore_bins ignore_dvm_cmp[]  = {'he};   
                                              bins values_dvm_msg[]         = {'hf};   

                                      <% } else if (obj.fnNativeInterface == "ACE-LITE") { %>
                                              bins values_legal_0_to_1[]    = {[0:1]};  
                                              ignore_bins ignore_7_to_2[]   = {[7:2]};
                                              bins values_legal_8_to_9[]    = {[8:9]};  
                                              ignore_bins ignore_a_to_c[]   = {['ha:'hc]};
                                              bins values_legal_d           = {'hd};  

                                      <% } else if (obj.fnNativeInterface == "ACELITE-E") { %>
                                              bins values_legal_0_to_1[]    = {[0:1]};  
                                              ignore_bins ignore_7_to_2[]   = {[7:2]};
                                              bins values_legal_8_to_9[]    = {[8:9]};  
                                              ignore_bins ignore_a_to_c[]   = {['ha:'hc]};
                                              bins values_legal_d           = {'hd};  
                                        <%if (obj.eAc) { %>
                                              ignore_bins ignore_dvm_cmp[]  = {'he};   
                                              bins values_dvm_msg[]         = {'hf};   
                                        <%}%>
                                      <%}%>

    }
<% for(let i=0; i<nTraceRegisters; i++) {%>
    cc_native_trig_opcode_snoop_matched_<%=i%> : cross cp_opcode_matched_<%=i%>, cp_native_trig_opcode_snoop {
                                                   ignore_bins matched_0  = binsof (cp_opcode_matched_<%=i%>) intersect {0}; // ignore when no match
                                                 }
<% } %>
<% } %>
<% } %>            // end is_opcode_matching_supported

    // #Cover.IOAIU.TTRI.native_dii_hit
    //#Cover.CHIAIU.TTRI.native_dii_hit
    cp_native_trig_dii_hit                : coverpoint fcov_native_trig_dii_hit;
    // #Cover.IOAIU.TTRI.native_dmi_hit
    //#Cover.CHIAIU.TTRI.native_dmi_hit
    cp_native_trig_dmi_hit                : coverpoint fcov_native_trig_dmi_hit;
    // #Cover.IOAIU.TTRI.native_dii_hui_nunitid
    //#Cover.CHIAIU.TTRI.native_dii_hui_nunitid
    cp_native_trig_dii_hui_nunitid        : coverpoint fcov_native_trig_hui iff(fcov_native_trig_dii_hit) {
                                            bins dii_hui_nunitid[] = {[0:2]};      // Khaleel said only values up to 2 need to be covered for NC 3.2, need to investigate change for NC 3.8
                                            ignore_bins above_2    = {[3:$]};
    }
    // #Cover.IOAIU.TTRI.native_dmi_hui_mig
    //#Cover.CHIAIU.TTRI.native_dmi_hui_mig
    cp_native_trig_dmi_hui_mig            : coverpoint fcov_native_trig_hui iff(fcov_native_trig_dmi_hit) {
                                            bins dmi_hui_mig[]     = {[0:2]};      // see cp_native_trig_dii_hui_nunitid 
                                            ignore_bins above_2    = {[3:$]};
    }

<% if (num_user_bits > 0) { %>
    // #Cover.IOAIU.TTRI.native_user
    //#Cover.CHIAIU.TTRI.native_user
    cp_native_trig_user_bit_0             : coverpoint fcov_native_trig_user[0];
<% } %>
<% if (num_user_bits >= 2) { %>
    cp_native_trig_user_bit_1             : coverpoint fcov_native_trig_user[1];
<% } %>
<% if (num_user_bits >= 3) { %>
    cp_native_trig_user_bit_2             : coverpoint fcov_native_trig_user[2];
<% } %>
<% if (num_user_bits >= 4) { %>
    cp_native_trig_user_msb_bit_<%=num_user_bits-1%> : coverpoint fcov_native_trig_user[<%=num_user_bits-1%>];
<% } %>

    // #Cover.IOAIU.TTRI.traceme_out_expected
    //#Cover.CHIAIU.TTRI.traceme_out_expected
    cp_traceme_out                        : coverpoint fcov_traceme_out;
  endgroup

  function new(string name = "trace_trigger_set");
    super.new(name);

<% for(let i=0; i<nTraceRegisters; i++) {%>
    trigger_reg_set[<%=i%>] = new("trace_trigger_set_<%=i%>");
<%}%>
    `ifndef FSYS_COVER_ON
    cg_trigger = new();
    `endif

  endfunction : new

  function bit gen_expected_traceme(
    // Usage: Pass the information from native interface.
    // If there are multiple sets of trigger registers (see parameter nTraceRegisters), this will call a lower function multiple times and OR the results.
    // Note: that before calling this function, TCTRLR_write_reg() probably should have been called to set the TCTRLR register bits.
    bit         native_trig_traceme, 
    bit [51:00] native_trig_addr,     // addr bits [11:0] will be ignored
    bit         native_trig_ar,       // should be 0 for CHI
    bit         native_trig_aw,       // should be 0 for CHI
    bit         native_trig_dii_hit, 
    bit         native_trig_dmi_hit, 
    bit   [4:0] native_trig_hui, 
    bit   [3:0] native_trig_memattr,
    bit  [14:0] native_trig_opcode, 
    bit  [31:0] native_trig_user,
    bit         is_chi, // 1 for CHI, 0 for IOAIU
    bit         is_dvm
  );

    bit[<%=nTraceRegisters%>-1:0] expected_traceme_bits;

<% if (isIoaiu) { %>
    // FIXME: upgrade this to an error if possible
    if ((native_trig_ar == 0) && (native_trig_aw == 0)) begin
      `uvm_info(get_name(), $psprintf("core%0d: Trigger utils saw both native_trig_ar and native_trig_aw equal 0, unexpected.", this.mpCoreId), UVM_MEDIUM)
    end
    if ((native_trig_ar == 1) && (native_trig_aw == 1)) begin
      `uvm_error(get_name(), $psprintf("core%0d: Trigger utils saw both native_trig_ar and native_trig_aw equal 1, unexpected.", this.mpCoreId))
    end
    // FIXME: upgrade this to an error if possible
    if ((native_trig_dii_hit == 0) && (native_trig_dmi_hit == 0)) begin
      `uvm_info(get_name(), $psprintf("core%0d: Trigger utils saw both native_trig_dii_hit and native_trig_dmi_hit equal 0, unexpected.", this.mpCoreId), UVM_MEDIUM)
    end
    if ((native_trig_dii_hit == 1) && (native_trig_dmi_hit == 1)) begin
      `uvm_error(get_name(), $psprintf("core%0d: Trigger utils saw both native_trig_dii_hit and native_trig_dmi_hit equal 1, unexpected.", this.mpCoreId))
    end
<% } %>

<% for(let i=0; i<nTraceRegisters; i++) {%>
    expected_traceme_bits[<%=i%>]= trigger_reg_set[<%=i%>].gen_expected_traceme_per_set(
      native_trig_traceme, 
      native_trig_addr,
      native_trig_ar,
      native_trig_aw,
      native_trig_dii_hit, 
      native_trig_dmi_hit, 
      native_trig_hui, 
      native_trig_memattr,
      native_trig_opcode, 
      native_trig_user,
      is_chi,
      is_dvm
    );
<%}
%>
    gen_expected_traceme = |(expected_traceme_bits);
    if (gen_expected_traceme) begin
      expected_traceme_1_count++; 
    end else begin
      expected_traceme_0_count++; 
    end
    `uvm_info(get_name(), $psprintf("core%0d: native_trig value: traceme = %0b, addr=%16x, ar=%0b, aw=%0b, dii_hit=%0b, dmi_hit=%0b, hui=%0h, memattr=%0h, opcode=%0h, user=%0h ", this.mpCoreId, native_trig_traceme, native_trig_addr, native_trig_ar, native_trig_aw, native_trig_dii_hit, native_trig_dmi_hit, native_trig_hui, native_trig_memattr, native_trig_opcode, native_trig_user), UVM_LOW)
    `uvm_info(get_name(), $psprintf("core%0d: expected_traceme_bits = %0b", this.mpCoreId, expected_traceme_bits), UVM_LOW)
    `uvm_info(get_name(), $psprintf("core%0d: expected_traceme_1_count = %0d, expected_traceme_0_count = %0d", this.mpCoreId, expected_traceme_1_count, expected_traceme_0_count), UVM_LOW)

    // set variables for fcov
    fcov_native_trig_traceme = native_trig_traceme;
    fcov_native_trig_addr    = native_trig_addr;
<% if (isIoaiu) { %>
    fcov_native_trig_ar      = native_trig_ar;
    fcov_native_trig_aw      = native_trig_aw;
<% } %>
    fcov_native_trig_dii_hit = native_trig_dii_hit;
    fcov_native_trig_dmi_hit = native_trig_dmi_hit;
    fcov_native_trig_hui     = native_trig_hui;            
    fcov_native_trig_memattr = native_trig_memattr;
<% if (isChi) { %>
    $cast(fcov_native_trig_opcode,native_trig_opcode);
<% } %>
<% if (isIoaiu) { %>
    fcov_native_trig_opcode  = native_trig_opcode;
<% } %>
    fcov_native_trig_user    = native_trig_user;
    // concatenate matched bits from different trigger sets to use for a coverpoint
    fcov_sets_native_matched = {
<% for(let i=nTraceRegisters-1; i>=1; i--) {%>
                                 trigger_reg_set[<%=i%>].master_init_traceme,
<% } %>
                                 trigger_reg_set[0].master_init_traceme
                               };
    fcov_sets_addr_matched = {
<% for(let i=nTraceRegisters-1; i>=1; i--) {%>
                                 trigger_reg_set[<%=i%>].addr_matched,
<% } %>
                                 trigger_reg_set[0].addr_matched
                               };
    fcov_sets_memattr_matched = {
<% for(let i=nTraceRegisters-1; i>=1; i--) {%>
                                 trigger_reg_set[<%=i%>].memattr_matched,
<% } %>
                                 trigger_reg_set[0].memattr_matched
                               };
<% if (is_opcode_matching_supported) { %>
    fcov_sets_opcode_matched = {
<% for(let i=nTraceRegisters-1; i>=1; i--) {%>
                                 trigger_reg_set[<%=i%>].opcode_matched,
<% } %>
                                 trigger_reg_set[0].opcode_matched
                               };
<% } %>
    fcov_sets_target_type_matched = {
<% for(let i=nTraceRegisters-1; i>=1; i--) {%>
                                 trigger_reg_set[<%=i%>].target_type_matched,
<% } %>
                                 trigger_reg_set[0].target_type_matched
                               };
<% if (num_user_bits > 0) { %>
    fcov_sets_user_matched = {
<% for(let i=nTraceRegisters-1; i>=1; i--) {%>
                                 trigger_reg_set[<%=i%>].user_matched,
<% } %>
                                 trigger_reg_set[0].user_matched
                               };
<% } %>
    fcov_sets_traceme        = expected_traceme_bits;
    fcov_traceme_out         = gen_expected_traceme;
   `ifndef FSYS_COVER_ON
    cg_trigger.sample();
    `endif
    return gen_expected_traceme;
  endfunction : gen_expected_traceme

  virtual function void TCTRLR_write_reg(int register_set, TRIG_TCTRLR_t wr_data);
    trigger_reg_set[register_set].TCTRLR_reg = wr_data;
    `uvm_info(get_name(), $psprintf("core%0d: Wrote TCTRLR[%0d] = %0h or %p", this.mpCoreId, register_set, wr_data, wr_data), UVM_HIGH)
  endfunction : TCTRLR_write_reg

  virtual function void TBALR_write_reg(int register_set, TRIG_TBALR_t wr_data);
    trigger_reg_set[register_set].TBALR_reg = wr_data;
    trigger_reg_set[register_set].TBAR_vreg[43:12] = trigger_reg_set[register_set].TBALR_reg[31:0];
  endfunction : TBALR_write_reg

  virtual function void TBAHR_write_reg(int register_set, TRIG_TBAHR_t wr_data);
    trigger_reg_set[register_set].TBAHR_reg = wr_data;
    trigger_reg_set[register_set].TBAR_vreg[51:44] = trigger_reg_set[register_set].TBAHR_reg[7:0];
  endfunction : TBAHR_write_reg

  virtual function void TOPCR0_write_reg(int register_set, TRIG_TOPCR0_t wr_data);
    trigger_reg_set[register_set].TOPCR0_reg = wr_data;
  endfunction : TOPCR0_write_reg

  virtual function void TOPCR1_write_reg(int register_set, TRIG_TOPCR1_t wr_data);
    trigger_reg_set[register_set].TOPCR1_reg = wr_data;
  endfunction : TOPCR1_write_reg

  virtual function void TUBR_write_reg(int register_set, TRIG_TUBR_t wr_data);
    trigger_reg_set[register_set].TUBR_reg = wr_data;
  endfunction : TUBR_write_reg

  virtual function void TUBMR_write_reg(int register_set, TRIG_TUBMR_t wr_data);
    trigger_reg_set[register_set].TUBMR_reg = wr_data;
  endfunction : TUBMR_write_reg

  virtual function void print_trigger_sets_reg_values();
<% for(let i=0; i<nTraceRegisters; i++) {%>
    trigger_reg_set[<%=i%>].print_trigger_set_reg_values();
<%}
%>
  endfunction : print_trigger_sets_reg_values

  virtual function void set_mpCoreId_value(int mpCoreId_in);
    this.mpCoreId=mpCoreId_in;
<% for(let i=0; i<nTraceRegisters; i++) {%>
    trigger_reg_set[<%=i%>].mpCoreId=mpCoreId_in;
<%}
%>
  endfunction : set_mpCoreId_value

endclass: trace_trigger_utils

