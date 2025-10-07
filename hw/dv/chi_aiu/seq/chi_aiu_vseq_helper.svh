

//
//Random delay class
//

class cnstr_random_delay extends uvm_object;

  `uvm_object_param_utils(cnstr_random_delay)

  int randomize_cnt;
  int divisor;
  int dly_min;
  int dly_max;
  rand int dly_res;

  constraint c_dly {
    dly_res inside {[dly_min : dly_max]};
  }

  extern function new(string s = "cnstr_random_delay");
  extern function void set_divisor(int val);
  extern function void set_range(int min, int max);

  extern function int get_value();

endclass: cnstr_random_delay

function cnstr_random_delay::new(string s = "cnstr_random_delay");
  super.new(s);

  randomize_cnt = 0;
  divisor       = 1;
  dly_min       = 0;
  dly_max       = 0;  
endfunction: new

function void cnstr_random_delay::set_divisor(int val);
  `ASSERT(val > 0);
  divisor = val;
endfunction: set_divisor

function void cnstr_random_delay::set_range(int min, int max);
  if (min > max) begin
    dly_min = max;
    dly_max = min;
  end else begin
    dly_min = min;
    dly_max = max;
  end
endfunction: set_range

function int cnstr_random_delay::get_value();
  if (++randomize_cnt % divisor == 0)
    this.randomize();

  return dly_res;
endfunction: get_value

