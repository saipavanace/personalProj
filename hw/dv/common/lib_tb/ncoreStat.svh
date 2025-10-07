class ncoreStat extends uvm_object;
   local real latency_sum;
   local real latency_sum_sq;
   local int  cnt;

   local real latency_min;
   local real latency_max;
   
   `uvm_object_param_utils( ncoreStat )

   function new(string name = " ");
      super.new(name);
      latency_sum    = 0.0;
      latency_sum_sq = 0.0;
      cnt            = 0;
      latency_min    = 2**20;
      latency_max    = 0.0;
   endfunction : new

   function void sample( longint v );
      real vr;
      if (v < 0) begin
	 `uvm_error($sformatf("%m"), $sformatf("input %h less than 0", v))
      end
      vr             = real'(v);
      latency_sum    += vr;
      latency_sum_sq += vr*vr;
      cnt            += 1;
      if (vr < latency_min) latency_min = vr;
      if (vr > latency_max) latency_max = vr;
   endfunction : sample

   function real get_min( );
      return latency_min;
   endfunction : get_min

   function real get_max( );
      return latency_max;
   endfunction : get_max

   function real get_mean( );
      return ((cnt > 0) ? (latency_sum/cnt) : 2**20);
   endfunction : get_mean

   function real get_stdev( );
      // sum(x)^2 - n*(avg(x))^2 = sum(x-avg(x))^2
      // = sum(x^2) - n*avg(x)^2 = sum(x^2) - sum(x)^2/n
      // Thus stdev =sqrt((sum(x^2) - (sum(x))^2/n)/(n-1))
      return( (cnt > 1) ? $sqrt((latency_sum_sq - (latency_sum*latency_sum)/cnt)/(cnt-1)) : 0 );
   endfunction : get_stdev
   
   function void print_stat( );
      int period;
      period = <%=obj.Clocks[0].params.period%>;
      `uvm_info($sformatf("%s", get_name()), $sformatf("LATENCY STATS:NS:%0d, Latency MIN:%.1e, MAX:%.1e, AVG:%.1e, STDV:%.1e",
						 cnt, latency_min/period, latency_max/period, get_mean()/period, get_stdev()/period), UVM_NONE)
   endfunction : print_stat

endclass : ncoreStat

