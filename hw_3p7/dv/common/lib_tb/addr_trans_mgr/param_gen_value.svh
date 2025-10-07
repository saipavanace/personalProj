
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
// Class : param_gen_value
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
class param_gen_value #(type T = int) extends uvm_object;
 
    //Members
    rand T rand_val;
    T      min_range;
    T      max_range;

    static param_gen_value #(T) m_val;
    
    //constraint
    constraint range_c { rand_val inside {[min_range:max_range]}; };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Function : new
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    local function new(string name = "param_gen_value");
        super.new(name);

        min_range = addrMgrConst::CONCERTO_MIN_ADDRESS_MAP;
        max_range = addrMgrConst::CONCERTO_MAX_ADDRESS_MAP;
    endfunction: new

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Function : set_min_range
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    function void set_min_range(T min_range);
        this.min_range = min_range;
    endfunction: set_min_range

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Function : set_max_range
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    function void set_max_range(T max_range);
        this.max_range = max_range;
    endfunction: set_max_range

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Function : pre_randomize
    // Description : Sanity check for constraints
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    function void pre_randomize();
        if(max_range < min_range) begin
`ifndef INCA
            $stacktrace;
`endif
            `uvm_fatal("ADDR MGR", {"TbError: param_gen_value ", $psprintf(
                "min_value:0x%0h for constraint is > max_value:0x%0h",
                 min_range, max_range)})
        end
    endfunction: pre_randomize

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Function : get_rand_value
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    function T get_rand_value();
        return(rand_val);
    endfunction: get_rand_value

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // Function : GetInstance
    //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    static function param_gen_value #(T) GetInstance();
        if(m_val == null)
            m_val = new("m_val");
        return(m_val);
    endfunction: GetInstance

endclass: param_gen_value
