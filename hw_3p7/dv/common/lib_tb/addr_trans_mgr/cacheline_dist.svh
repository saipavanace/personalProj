////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

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
// Class : cacheline_dist
// Description : Configure New cacheline generation propability
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
class cacheline_dist extends uvm_object;

    //members
    rand bit new_cacheline;
    int      posb;
    int      not_posb;

    //constraint
    constraint dist_c {
        new_cacheline dist { 1 := posb, 0 := not_posb};
    }

    //constructor
    function new(string name = "cacheline_dist");
        super.new(name);
    endfunction: new

    //set possibility
     function void set_posb(int posb);
         this.posb      = posb;
         this.not_posb  = 100 - posb;
     endfunction: set_posb

     //Debug
     function void post_randomize();
         //string msg;
         //msg = $psprintf("Gen new cacheline = %b; chance to gen new cacheline = %3d", new_cacheline, posb);
         //`uvm_info("ADDR MGR", msg, UVM_HIGH);
     endfunction: post_randomize

endclass: cacheline_dist
