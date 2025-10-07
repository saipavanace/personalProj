//
//Class implements CHI supported CACHE model
//  Data is stored in the form of bytes so that it can
//  support all bus width configurations, 128, 256 etc
//  without having to add any prep code
//

class chi_cache_info extends uvm_object;

  chi_bfm_cache_state_t  m_state;
  addr_width_t           m_addr;
  bit [7:0]              m_data[64];
  bit                    m_be[64];

  `uvm_object_param_utils(chi_cache_info)

  //
  //Interface Methods
  //
  extern function new(string s = "chi_cache_info");
  extern function chi_bfm_cache_state_t get_cacheline_state();
  extern function addr_width_t          get_cacheline();
  extern function byte_64_t             get_cacheline_data();
  extern function bit_64_t              get_cacheline_be();

  extern function void set_cacheline_state(
    chi_bfm_cache_state_t state,
    bit no_checks = 0);
  extern function void set_cacheline_addr(addr_width_t addr);
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
 `ifndef VCS
  extern local function void set_valid_bytes(
 `else // `ifndef VCS
  extern  function void set_valid_bytes(
 `endif // `ifndef VCS
<% } else {%>
  extern local function void set_valid_bytes(
<% } %>
    int byte_loc,
    bit [7:0] data,
    bit be);

  extern function void reset_data();
  
endclass: chi_cache_info

function chi_cache_info::new(string s = "chi_cache_info");
  super.new(s);
endfunction: new

function chi_bfm_cache_state_t chi_cache_info::get_cacheline_state();
  return m_state;
endfunction: get_cacheline_state

function bit [addrMgrConst::W_SEC_ADDR - 1 : 0] chi_cache_info::get_cacheline();
  return m_addr;
endfunction: get_cacheline

function byte_64_t chi_cache_info::get_cacheline_data();
  return m_data;
endfunction: get_cacheline_data

function bit_64_t chi_cache_info::get_cacheline_be();
  return m_be;
endfunction: get_cacheline_be

//no_checks is set if we want BFM to install cacheline in illegal state
//purposefully (example: on transport errors)
function void chi_cache_info::set_cacheline_state(
  chi_bfm_cache_state_t state,
  bit no_checks = 0);

  case (m_state) 
    CHI_IX:  m_state = state;
    CHI_SC: begin
      `ASSERT(m_state != CHI_SD);
      m_state = state;
    end
    CHI_SD:  m_state = state;
    CHI_UC:  m_state = state;
    CHI_UCE: m_state = state;
    CHI_UD:  m_state = state;
    CHI_UDP: m_state = state;
  endcase
endfunction: set_cacheline_state;

function void chi_cache_info::set_cacheline_addr(addr_width_t addr);
  m_addr = addr;
endfunction: set_cacheline_addr

function void chi_cache_info::set_valid_bytes(
  int byte_loc,
  bit [7:0] data,
  bit be);

  m_be[byte_loc] = be;
  if (be)
    m_data[byte_loc] = data;
  else
    m_data[byte_loc] = 0;
endfunction: set_valid_bytes

function void chi_cache_info::reset_data();
  for (int i = 0; i < 64; ++i) begin
    m_data[i] = 0;
    m_be[i]   = 0;
  end
endfunction: reset_data

