//usage: include in pkg



//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
//general purpose helpers

//minimum of 2 ints            
function int min(int a, int b);
    return (a<b)?a:b;          
endfunction : min              

function int max(int a, int b);
   return (a<b)?b:a;
endfunction : max

<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'io_aiu') ||(obj.testBench=="fsys")) { %>
   `ifdef VCS
    `define VCSorCDNS
   `elsif CDNS
    `define VCSorCDNS
   `endif 
<% }  %>
//---------------------------------------------------------------------------------
//translate axi params from smi_seq_item(s) 
//---------------------------------------------------------------------------------
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'io_aiu') ||(obj.testBench=="fsys")) { %>
`ifndef VCSorCDNS
typedef smi_seq_item;
`endif
<% } else { %>
typedef smi_seq_item;
<% } %>
//translate concerto attributes to axcache
// see ncoresysarch table 8
function static axi_axcache_t axcache(smi_seq_item cmd);
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    // The original table is in-appropriate. Should use DII specific table in 4.2.2.4.1.1
    // For DII: the fields of smi_ca and smi_ac are don't care. smi_ch hs to be 0
    // As a result the following table is obsolete
//    case({cmd.smi_st, cmd.smi_ca, cmd.smi_ac, cmd.smi_vz, cmd.smi_ch, cmd.smi_order})
//        {1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 2'b11}	:	axcache = 4'b0000 ;	// Read/Write        CmdRdNC, CmdWrNC
//        {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11}	:	axcache = 4'b0001 ;	// Read/Write        CmdRdNC, CmdWrNC
//        {1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b10}	:	axcache = 4'b0010 ;	// Read/Write        CmdRdNC, CmdWrNC
//        {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10}	:	axcache = 4'b0011 ;	// Read/Write        CmdRdNC, CmdWrNC
//        {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b0110 ;	// Read              ReadNITC
//        {1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b0110 ;	// Write             WriteUnique
//        {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b0111 ;	// Read              ReadNITC
//        {1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b0111 ;	// Write             WriteUnique
//        {1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b1010 ;	// Read              ReadNITC
//        {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b1010 ;	// Write             WriteUnique
//        {1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b1011 ;	// Read              ReadNITC
//        {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b1011 ;	// Write             WriteUnique
//        {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b1110 ;	// Read / Write      ReadNITC / WriteUnique
//        {1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 2'b10}	:	axcache = 4'b1111 ;	// Read/Write        ReadNITC / WriteUnique
        // default :   `uvm_error($sformatf("%m"), $sformatf(
        //     "caching attributes do not translate to axcache: st=%p  ca=%p  ac=%p  vz=%p  ch=%p  order=%p",
        //     smi_st, smi_ca, smi_ac, smi_vz, smi_ch, smi_order
        // ))
//    endcase

      // NOTE: in NCORE3.0/3.1, all accesses are non-bufferable due to ordering issues
      case ({cmd.smi_st, cmd.smi_vz, cmd.smi_order})
	  {1'b1, 1'b1, 2'b11} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc
        //  {1'b1, 1'b1, 2'b10} : axcache = 4'b0001;                  // Read/Write         CmdRdNC, CmdWrNc	
          {1'b1, 1'b1, 2'b10} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc	
          {1'b1, 1'b1, 2'b01} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc	
          {1'b1, 1'b1, 2'b00} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc	
        //  {1'b1, 1'b0, 2'b11} : axcache = 4'b0001;                  // Read/Write         CmdRdNC, CmdWrNc
          {1'b1, 1'b0, 2'b11} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc	
        //  {1'b1, 1'b0, 2'b10} : axcache = 4'b0001;                  // Read/Write         CmdRdNC, CmdWrNc	    
          {1'b1, 1'b0, 2'b10} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc       
          {1'b1, 1'b0, 2'b01} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc       
        //  {1'b1, 1'b0, 2'b00} : axcache = 4'b0001;                  // Read/Write         CmdRdNC, CmdWrNc	    
          {1'b1, 1'b0, 2'b00} : axcache = 4'b0000;                  // Read/Write         CmdRdNC, CmdWrNc       
          {1'b0, 1'b1, 2'b10} : axcache = 4'b0010;                  // Read/Write         CmdRdNC, CmdWrNc       
          {1'b0, 1'b1, 2'b01} : axcache = 4'b0010;                  // Read/Write         CmdRdNC, CmdWrNc       
          {1'b0, 1'b1, 2'b00} : axcache = 4'b0010;                  // Read/Write         CmdRdNC, CmdWrNc       
        //  {1'b0, 1'b0, 2'b10} : axcache = 4'b0011;                  // Read/Write         CmdRdNC, CmdWrNc       
          {1'b0, 1'b0, 2'b10} : axcache = 4'b0010;                  // Read/Write         CmdRdNC, CmdWrNc       
          {1'b0, 1'b0, 2'b01} : axcache = 4'b0010;                  // Read/Write         CmdRdNC, CmdWrNc       
        //  {1'b0, 1'b0, 2'b00} : axcache = 4'b0011;                  // Read/Write         CmdRdNC, CmdWrNc       
          {1'b0, 1'b0, 2'b00} : axcache = 4'b0010;                  // CMO operations: No AXI4 equivalent. TODO: ACE-lite?
        // for 3.2, 0011 is allowed, and DII translates this to 0000.
        // WARNING: this behavior is not correct, but should work. The following is a temporary fix. Need to revisit for 3.4 and later.
        // FIX ME!!!!
          {1'b0, 1'b0, 2'b11} : axcache = 4'b0010;                  // Changed as part of CONC-17677
          {1'b0, 1'b1, 2'b11} : axcache = 4'b0010;                  // Changed as part of CONC-17677
          default :  begin
             `uvm_error($sformatf("%m"), $sformatf(
                                                   "caching attributes do not translate to axcache: st=%p  ex=%p ca=%p  ac=%p  vz=%p  ch=%p  order=%p (src=%p addr=%p)",
                                                   cmd.smi_st, cmd.smi_es, cmd.smi_ca, cmd.smi_ac, cmd.smi_vz, cmd.smi_ch, cmd.smi_order, cmd.smi_src_id, cmd.smi_addr
          					   ))
          end
      endcase
endfunction : axcache


//translate axi burst
function static axi_axburst_t axburst(smi_seq_item cmd);
    axi_axburst_t burst_type;
    bit my_explicit_incr;
    int axi_len;
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    my_explicit_incr = explicit_incr(cmd);
    axi_len = axlen(cmd);
    if (axi_len == 0) begin
      burst_type =  AXIINCR ;
    end else begin
      if(my_explicit_incr) begin
         burst_type =  AXIINCR ;  // device access may have INCR burst
      end else if (cmd.smi_tof == SMI_TOF_CHI) begin
         if ((cmd.smi_st && cmd.isCmdNcRdMsg()) || ((2**cmd.smi_size) <= (WXDATA/8))) begin
	    burst_type =  AXIINCR ;  // WRAP fitting within 1 axi beat represented as axi INCR
         end else begin
	    burst_type = AXIWRAP;
         end
      end else if (cmd.smi_tof != SMI_TOF_CHI) begin
         if (cmd.smi_st) begin
	    burst_type = cmd.smi_mpf1_burst_type;  // take from mpf1
         end else if ( (cmd.smi_tof != SMI_TOF_CHI) && (((2**cmd.smi_size) - (cmd.smi_addr % (WXDATA/8-1))) <= (WXDATA/8)) ) begin
	    burst_type =  AXIINCR;
         end else begin
	    burst_type = AXIWRAP;
         end
      end
    end
    `uvm_info($sformatf("%m"), $sformatf("GENBURST: msg_type=%02h burst_type=%p tof=%0d st=%0d bt=%0d smi_size=%0h asize=%0d alen=%0d WXDATA=%0h addr=%p explicit_incr=%0d AsALWD=%0d ALN=%0d",
					 cmd.smi_msg_type, burst_type, cmd.smi_tof, cmd.smi_st, cmd.smi_mpf1_burst_type, cmd.smi_size, cmd.smi_mpf1_asize, cmd.smi_mpf1_alength, WXDATA/8,
					 cmd.smi_addr, my_explicit_incr, (cmd.smi_mpf1_alength+1)*(2**cmd.smi_mpf1_asize)<=(WXDATA/8), ((cmd.smi_addr & ((2**cmd.smi_size)-1)) != 0)), UVM_HIGH)
    axburst = burst_type;
endfunction : axburst

//translate axi length
//numbeats required to represent on axi
// = axlen + 1
function static axi_axlen_t axlen(smi_seq_item cmd);
    int offset;
    int asize;
    bit my_explicit_incr;
    int	bytes_touched;
   
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    bytes_touched     = (((cmd.smi_tof != SMI_TOF_CHI) && (cmd.smi_mpf1_burst_type == INCR)) || (cmd.smi_st && cmd.isCmdNcRdMsg())) ? axi_bytes_touched(cmd) : axi_bytes(cmd);
    my_explicit_incr  = explicit_incr(cmd);
    asize             = axsize(cmd);
    offset            = 0;
    if(cmd.isCmdNcWrMsg() && my_explicit_incr)  offset = ((cmd.smi_addr & ({WXDATA{1'b1}} << asize)) % (WXDATA/8));  //wr incr may require an extra beat

    // default axlen based on smi_size
    axlen = ((2**cmd.smi_size)/(WXDATA/8)) - (((2**cmd.smi_size)/(WXDATA/8)) ? 1 : 0);

    // adjust
    if (cmd.smi_st) begin
       if (cmd.smi_tof != SMI_TOF_CHI) begin
          if (narrow(cmd)) begin
             axlen = cmd.smi_mpf1_alength;
          end else begin
	     if (cmd.smi_mpf1_burst_type != INCR) begin
                axlen = (2**cmd.smi_size)/min(2**cmd.smi_mpf1_asize, (WXDATA/8));
	     end else begin
	        axlen = $ceil((real'(bytes_touched))/(narrow(cmd)?2**cmd.smi_mpf1_asize:(WXDATA/8)));
	     end
`uvm_info($sformatf("%m"), $sformatf("AXLEN: axlen raw = %0d, axlen ceil = %0d", bytes_touched/min(2**cmd.smi_mpf1_asize, (WXDATA/8)), $ceil(bytes_touched/min(2**cmd.smi_mpf1_asize, (WXDATA/8)))), UVM_HIGH)
	     if (axlen > 0) axlen = axlen - 1;
          end
       end else begin // CHI
	  if (cmd.isCmdNcRdMsg()) begin
             axlen = (((2**cmd.smi_size)-(cmd.smi_addr%(2**cmd.smi_size)))/(WXDATA/8));
             // need to adjust (-1 if > 1)
             axlen = axlen - (((axlen > 0)&&((cmd.smi_addr%(WXDATA/8))==0))?1:0);
	  end
       end // else: !if(cmd.smi_tof != SMI_TOF_CHI)
    end // if (cmd.smi_st)
    `uvm_info($sformatf("%m"), $sformatf("GENAXLEN: narrow=%0d touchend=%0d mpf1_len=%0d axi_len=%0d", narrow(cmd), bytes_touched, cmd.smi_mpf1_alength, axlen), UVM_HIGH)
endfunction : axlen

//translate axi size 
// = 2**axsize
function static axi_axsize_t axsize(smi_seq_item cmd);
    bit my_narrow;
   
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    my_narrow = narrow(cmd);
    if(cmd.smi_st) begin
        if ( cmd.smi_tof == SMI_TOF_CHI ) begin
	   axsize = min(cmd.smi_size, $clog2(WXDATA/8));
	end else begin
           if (cmd.isCmdNcRdMsg()) begin
              axsize = min(cmd.smi_mpf1_asize, $clog2(WXDATA/8));
           end else begin
              axsize = (my_narrow == 0) ? (cmd.smi_mpf1_alength > 0) ? min(cmd.smi_mpf1_asize, $clog2(WXDATA/8)) : $clog2(WXDATA/8) : min(cmd.smi_mpf1_asize, $clog2(WXDATA/8));
           end
	end
    end else begin
        if(my_narrow) axsize =      ((cmd.smi_tof == SMI_TOF_CHI) || (cmd.smi_st == 0)) ? min(cmd.smi_size, $clog2(WXDATA/8)) : min(cmd.smi_mpf1_asize, $clog2(WXDATA/8));    // narrow read -> use verbatim size
        else          axsize =      $clog2( min(axi_bytes(cmd), (WXDATA/8)) ); // other read must not overshoot
    end
    `uvm_info($sformatf("%m"), $sformatf("AXSIZE: axsize=%0h", axsize), UVM_DEBUG)
endfunction : axsize

//helper: axi of this cmd is narrow wrt target?
function static bit narrow(smi_seq_item cmd);

    bit optimizeNarrow;

    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    narrow = 0;
    if (
//        ((cmd.smi_tof != SMI_TOF_CHI) && cmd.isCmdNcRdMsg())              // wr uses byteenables instead of narrow 
        (cmd.smi_tof != SMI_TOF_CHI) && (cmd.smi_st == 1) && ((2**cmd.smi_mpf1_asize) < (WXDATA/8)) // upstream was narrow
    ) begin
        narrow = (! optimize_narrow(cmd)) ;
    end 
endfunction : narrow

function static bit optimize_narrow(smi_seq_item cmd);
    smi_addr_t end_addr;
   
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))
   
    end_addr = ((cmd.smi_addr&(~((2**cmd.smi_mpf1_asize)-1)))+((cmd.smi_mpf1_alength+1)*(2**cmd.smi_mpf1_asize)));           // last addr + 1 in axi
    optimize_narrow = (
		      ( (cmd.smi_tof == SMI_TOF_CHI) || (cmd.smi_st == 0) )
		      &&
		      ( ( (end_addr % (WXDATA/8)) == 0 )                        // end aligned wrt target width
			|| (
			    (axi_bytes(cmd) < (WXDATA/8))                             // axi fits within one downstream beat
			    && (cmd.smi_mpf1_alength[0] == 1)                         // even number of upstream axi beats
			    && ( ((cmd.smi_addr) % (WXDATA/8)) == 0 )                 // beginning aligned wrt target width
			    )
		      )
		      );
endfunction : optimize_narrow

//helper: compute number of bytes accessed by axi
function static int axi_bytes_touched(smi_seq_item cmd);
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    axi_bytes_touched = axi_bytes(cmd);

    if ( cmd.isCmdNcRdMsg() || cmd.isCmdNcWrMsg() ) begin
       if(cmd.smi_st) begin
	  if (cmd.smi_tof == SMI_TOF_CHI) begin
	     if (cmd.isCmdNcRdMsg()) begin
		axi_bytes_touched -= ( cmd.smi_addr % (2**cmd.smi_size) ) ;       // transform chi wrap into incr for NcRdMsg
		`uvm_info($sformatf("%m"), $sformatf("Touched 0: addr:%p", cmd.smi_addr), UVM_HIGH)
	     end
	  end else begin
	     axi_bytes_touched -= ( cmd.smi_addr % (2**cmd.smi_mpf1_asize) ) ; // axi incr runs from size aligned addr to no further than last axi beat.
	     `uvm_info($sformatf("%m"), $sformatf("Touched 1: addr:%p", cmd.smi_addr), UVM_HIGH)
	  end
       end else begin
     `uvm_info($sformatf("%m"), $sformatf("Touched 2: addr:%p", cmd.smi_addr), UVM_HIGH)
     /* wrong code: deleted to fix CONC-11060
	  if ((cmd.smi_tof != SMI_TOF_CHI) && ( (cmd.smi_mpf1_alength==0) || (explicit_incr(cmd)))) begin
             axi_bytes_touched -= ( cmd.smi_addr % ((cmd.smi_mpf1_alength>0)?(2**cmd.smi_size):(2**cmd.smi_mpf1_asize)) ) ; // axi incr accesses should not be merged, but they are for now
             `uvm_info($sformatf("%m"), $sformatf("Touched 3: addr:%p", cmd.smi_addr), UVM_HIGH)
     end
     */
       end // else: !if(cmd.smi_st)
    end // if ( cmd.isCmdNcRdMsg() || cmd.isCmdNcWrMsg() )
   
    `uvm_info($sformatf("%m"), $sformatf("TOUCHED: axi_byte=%0d touched=%0d (addr=%p tof=%0d asize=%0d offset=%0h)",
					 axi_bytes(cmd), axi_bytes_touched, cmd.smi_addr, cmd.smi_tof, cmd.smi_mpf1_asize, cmd.smi_addr % (2**cmd.smi_mpf1_asize)), UVM_HIGH)
endfunction : axi_bytes_touched

//helper: compute number of bytes of upstream axi frame
function static int axi_bytes(smi_seq_item cmd);
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    if(explicit_incr(cmd))      axi_bytes = ((cmd.smi_tof != SMI_TOF_CHI) && (cmd.smi_st == 1)) ? ( ((cmd.smi_mpf1_alength) + 1) * (2**(cmd.smi_mpf1_asize)) ) : (2**cmd.smi_size);
    else                        axi_bytes = (2**(cmd.smi_size));                                           // any access which began as WRAP
endfunction : axi_bytes

//helper: device access may specify INCR burst
function static bit explicit_incr(smi_seq_item cmd);
    int mpf1_end_axi_addr;
    int mpf1_start_axi_addr;
    bit chi_explicit_incr;
 
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))

    if (cmd.smi_tof != SMI_TOF_CHI) begin
       mpf1_start_axi_addr = (cmd.smi_addr & ((1 << cmd.smi_mpf1_asize)-1)) & ((WXDATA/8)-1);
       mpf1_end_axi_addr   = (2**cmd.smi_mpf1_asize) * (cmd.smi_mpf1_alength+1) + mpf1_start_axi_addr;
       `uvm_info($sformatf("%m"), $sformatf("START %0h END %0h asize %0d mpf1size %0h addr %p",
					    mpf1_start_axi_addr, mpf1_end_axi_addr, cmd.smi_mpf1_asize, (2**cmd.smi_mpf1_asize)*(cmd.smi_mpf1_alength+1), cmd.smi_addr), UVM_HIGH)
    end

    chi_explicit_incr = ( cmd.isCmdNcRdMsg() && cmd.smi_st && (((2**cmd.smi_size)-(cmd.smi_addr%(2**cmd.smi_size))) <= (WXDATA/8)) );
    return (
        ( (cmd.smi_tof inside {SMI_TOF_AXI, SMI_TOF_ACE} ) &&
	  (((cmd.smi_st == 1) && (cmd.smi_mpf1_burst_type == INCR)) ||
           ((cmd.smi_st == 0) && ((2**cmd.smi_size) <= (WXDATA/8)))) ) ||
        ( (cmd.smi_tof == SMI_TOF_CHI) && chi_explicit_incr )
    );
endfunction : explicit_incr


//----------------------------------------------------------------------------------
//translate axi addr
function static axi_axaddr_t axaddr(smi_seq_item cmd);
    if(cmd.smi_st && (cmd.smi_ca == 0)) begin
       if (cmd.smi_tof == SMI_TOF_CHI) begin
	  if (cmd.isCmdNcWrMsg()) begin
	     if (cmd.smi_st == 0) begin
		axaddr = (cmd.smi_addr&(~(min((WXDATA/8),(2**cmd.smi_size))-1)));
	     end else begin
		axaddr = (cmd.smi_addr&(~(min((WXDATA/8),(2**cmd.smi_size))-1)));
	     end
	  end else begin
	     axaddr = (cmd.smi_st) ? cmd.smi_addr : (cmd.smi_addr&(~(min((WXDATA/8),(2**cmd.smi_size))-1)));
	  end
       end else begin
          axaddr = ( ((2**cmd.smi_size)<=(WXDATA/8)) || ((cmd.smi_intfsize+3) >= cmd.smi_mpf1_asize) ) ? cmd.smi_addr : cmd.smi_addr & (~((WXDATA/8)-1));  // FIXME!!!!: read address should not change
       end
    end else begin
        axaddr = (cmd.smi_addr & ({WSMIADDR{1'b1}} << axsize(cmd)));  //axi wrap addr must align to axi size.  wrap->incr most easily expressed aligned.
    end
   `uvm_info($sformatf("%m"), $sformatf("AXADDR: =%p, smi addr=%p tof=%0d st=%0d size=%d asize=%d wsize=%0h",
					axaddr, cmd.smi_addr, cmd.smi_tof, cmd.smi_st, cmd.smi_size, cmd.smi_mpf1_asize, (WXDATA/8)), UVM_HIGH)
endfunction : axaddr

//translate axi data
//precondition: all required data present in txn
typedef axi_xdata_t axi_xdata_arr_t[];  //to enable array return
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'io_aiu') || (obj.testBench=="fsys")) { %>
`ifdef VCSorCDNS
typedef bit [63:0] smi_dat_flat_t0;
typedef bit [127:0] smi_dat_flat_t1;
typedef bit [255:0] smi_dat_flat_t2;
typedef bit [511:0] smi_dat_flat_t3;
typedef bit [1023:0] smi_dat_flat_t4;
typedef bit [2047:0] smi_dat_flat_t5;
typedef bit [191:0] smi_dat_flat_t6;
typedef bit [(2**6)-1 : 0][8-1 : 0]  smi_dat_flat_t;
typedef bit [63:0] smi_dat_flat_t_0;
typedef bit [127:0] smi_dat_flat_t_1;
typedef bit [255:0] smi_dat_flat_t_2;
typedef bit [511:0] smi_dat_flat_t_3;
typedef bit [1023:0] smi_dat_flat_t_4;
typedef bit [2047:0] smi_dat_flat_t_5;
typedef bit [191:0] smi_dat_flat_t_6;
typedef bit [(CACHELINESIZE/8)-1     : 0] smi_be_flat_t0;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE/4)-1     : 0] smi_be_flat_t1;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE/2)-1     : 0] smi_be_flat_t2;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE)-1     : 0]   smi_be_flat_t3;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE*2)-1     : 0] smi_be_flat_t4;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE*4)-1     : 0] smi_be_flat_t5;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [((CACHELINESIZE/8)/8)-1 : 0] smi_dbad_flat_t0;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE/4)/8)-1 : 0] smi_dbad_flat_t1;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE/2)/8)-1 : 0] smi_dbad_flat_t2;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE)/8)-1 : 0]   smi_dbad_flat_t3;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE*2)/8)-1 : 0] smi_dbad_flat_t4;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE*4)/8)-1 : 0] smi_dbad_flat_t5;  //large enough to hold maximal size access.  little endian.
typedef bit [(CACHELINESIZE/8)-1     : 0] smi_be_flat_t_0;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE/4)-1     : 0] smi_be_flat_t_1;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE/2)-1     : 0] smi_be_flat_t_2;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE)-1     : 0]   smi_be_flat_t_3;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE*2)-1     : 0] smi_be_flat_t_4;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [(CACHELINESIZE*4)-1     : 0] smi_be_flat_t_5;    //large enough to hold two copies of maximal size access.  little endian.
typedef bit [((CACHELINESIZE/8)/8)-1 : 0] smi_dbad_flat_t_0;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE/4)/8)-1 : 0] smi_dbad_flat_t_1;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE/2)/8)-1 : 0] smi_dbad_flat_t_2;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE)/8)-1 : 0]   smi_dbad_flat_t_3;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE*2)/8)-1 : 0] smi_dbad_flat_t_4;  //large enough to hold maximal size access.  little endian.
typedef bit [((CACHELINESIZE*4)/8)-1 : 0] smi_dbad_flat_t_5;  //large enough to hold maximal size access.  little endian.
smi_dat_flat_t1 smi_dat_flat_1;
smi_dat_flat_t2 smi_dat_flat_2;
smi_dat_flat_t3 smi_dat_flat_3;
smi_dat_flat_t4 smi_dat_flat_4;
`endif // `ifdef VCSorCDNS
<% } %>
function static axi_xdata_arr_t xdata(smi_seq_item cmd, smi_seq_item dtx, axi_xdata_arr_t template = {}, bit from_check = 1);
    bit[(2**6)-1 : 0][8-1 : 0] smi_dat_flat;  
    int smi_addr_intfsize_offset;
    int smi_base_intfsize_offset;
    int smi_intfsize;
    int smi_size;   
    int	bus_size;
    int smi_addr_wrap_top;
    int smi_addr_wrap_base;
    int axi_addr_wrap_base;   

    //
    bit	my_explicit_incr;
    bit	my_narrow;
    int axi_len;
    int axi_size;
    int smi_addr_bus_offset;
    //
    int num_slices;
    int first_slice;
    //
    int all_bytes;
    axi_xstrb_t m_xstrb[];
    //
    int smi_flat_offset;
    int axi_flat_offset;
    int axi_beat;
    int axi_narrow_offset;
    int axi_beat_offset;

    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))
    if(!dtx.isDtrMsg() && !dtx.isDtwMsg())  `uvm_error($sformatf("%m"), $sformatf("not a data message type"))

    my_explicit_incr = explicit_incr(cmd);
    my_narrow = narrow(cmd);
    axi_len = axlen(cmd) + 1;

    `uvm_info($sformatf("%m"), $sformatf("smi data=%p", dtx.smi_dp_data), UVM_HIGH)

    //read input data: assume data is on smi_*x2_
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi') || (obj.testBench == 'io_aiu') || (obj.testBench=="fsys")) { %>
`ifdef VCS
    if(dtx.smi_dp_data.size*wSmiDPdata==64)
      smi_dat_flat = smi_dat_flat_t'({ { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t0'(dtx.smi_dp_data)}}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==128)
      smi_dat_flat = smi_dat_flat_t'({ { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t1'(dtx.smi_dp_data)}}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==256)
      smi_dat_flat = smi_dat_flat_t'({ { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t2'(dtx.smi_dp_data)}}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==512)
      smi_dat_flat = smi_dat_flat_t'({ { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t3'(dtx.smi_dp_data)}}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==1024)
      smi_dat_flat = smi_dat_flat_t'({ { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t4'(dtx.smi_dp_data)}}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==2048)
      smi_dat_flat = smi_dat_flat_t'({ { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t5'(dtx.smi_dp_data)}}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==192)
      smi_dat_flat = smi_dat_flat_t'({ { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t6'(dtx.smi_dp_data)}}}) ;  //outer concat puts data in lsbs
`elsif CDNS // `ifdef VCS
    if(dtx.smi_dp_data.size*wSmiDPdata==64)
      smi_dat_flat = smi_dat_flat_t_0'({ << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t0'(dtx.smi_dp_data)}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==128)
      smi_dat_flat = smi_dat_flat_t_1'({ << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t1'(dtx.smi_dp_data)}}) ;  //outer concat puts data in lsbs
    else if(dtx.smi_dp_data.size*wSmiDPdata==256)
     begin
      smi_dat_flat = smi_dat_flat_t_2'({ << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t2'(dtx.smi_dp_data)}}) ;  //outer concat puts data in lsbs
    `uvm_info($sformatf("%m"), $sformatf("smi data_2=%p , size =%0h data=%0h", dtx.smi_dp_data, dtx.smi_dp_data.size ,wSmiDPdata), UVM_HIGH)
    end
    else if(dtx.smi_dp_data.size*wSmiDPdata==512)
     begin
      smi_dat_flat = smi_dat_flat_t_3'({ << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t3'(dtx.smi_dp_data)}}) ;  //outer concat puts data in lsbs
    `uvm_info($sformatf("%m"), $sformatf("smi data_3=%p , size =%0h data=%0h", dtx.smi_dp_data, dtx.smi_dp_data.size ,wSmiDPdata), UVM_HIGH)
    end
    else if(dtx.smi_dp_data.size*wSmiDPdata==1024)
     begin
      smi_dat_flat = smi_dat_flat_t_4'({ << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t4'(dtx.smi_dp_data)}}) ;  //outer concat puts data in lsbs
    `uvm_info($sformatf("%m"), $sformatf("smi data_4=%p , size =%0h data=%0h", dtx.smi_dp_data, dtx.smi_dp_data.size ,wSmiDPdata), UVM_HIGH)
    end
    else if(dtx.smi_dp_data.size*wSmiDPdata==2048)
     begin
      smi_dat_flat = smi_dat_flat_t_5'({ << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t5'(dtx.smi_dp_data)}}) ;  //outer concat puts data in lsbs
    `uvm_info($sformatf("%m"), $sformatf("smi data_5=%p , size =%0h data=%0h", dtx.smi_dp_data, dtx.smi_dp_data.size ,wSmiDPdata), UVM_HIGH)
    end
    else if(dtx.smi_dp_data.size*wSmiDPdata==192)
     begin
      smi_dat_flat = smi_dat_flat_t_6'({ << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {smi_dat_flat_t6'(dtx.smi_dp_data)}}) ;  //outer concat puts data in lsbs
    `uvm_info($sformatf("%m"), $sformatf("smi data_6=%p , size =%0h data=%0h", dtx.smi_dp_data, dtx.smi_dp_data.size ,wSmiDPdata), UVM_HIGH)
    end
`else
    smi_dat_flat = { { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {dtx.smi_dp_data}} } ;  //outer concat puts data in lsbs
`endif // `ifdef ... `else ... CDNS
<% } else { %>
    smi_dat_flat = { { << (<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>==0?wSmiDPdata:<%=obj.interfaces.smiRxInt[obj.interfaces.smiRxInt.length-1].params.wSmiDPdata%>) {dtx.smi_dp_data}} } ;  //outer concat puts data in lsbs
<% } %>

    smi_size      = 2**cmd.smi_size;
    smi_intfsize  = 2**(cmd.smi_intfsize+3);
    bus_size      = (WXDATA/8);
   
    //read out axi
    // don't care about disabled bytes.  rd behaves as if all axi frame bytes enabled. 
    axi_size                 = 2**(my_narrow?cmd.smi_mpf1_asize:axsize(cmd));
    smi_addr_wrap_base       = (cmd.smi_addr & (~(smi_size-1))) % smi_intfsize;
    smi_addr_wrap_top        = (smi_addr_wrap_base + smi_size);
    axi_addr_wrap_base       = (cmd.smi_addr & (~(smi_size-1))) % bus_size;
   
    smi_addr_intfsize_offset = cmd.smi_addr % smi_intfsize ;
    smi_base_intfsize_offset = (bus_size < smi_intfsize) ? ( (cmd.smi_addr & (~(smi_size-1))) % smi_intfsize ) : 0;
    
    smi_addr_bus_offset      = (cmd.smi_addr % bus_size) ;

    num_slices  = ( my_narrow ) ? (bus_size / axi_size) : 1;
    first_slice = ( my_narrow ) ? ( (axaddr(cmd) % bus_size) / axi_size ) : 0;
    
    //don't care about disabled bytes.  rd behaves as if all axi frame bytes enabled. 
    // !!coding style - susceptible to false pass if data filler loop does not overwrite correctly
    xdata = new[axi_len];
    if (xdata.size() != template.size() && from_check == 1) begin
        `uvm_info($sformatf("%m"), $sformatf("Warning: xdata=%0d, template=%0d smi_addr=%p", xdata.size(), template.size(), cmd.smi_addr),UVM_DEBUG) 
    end

    for (int i=0; i<xdata.size(); i++)
      xdata[i] = template[i];
   
    m_xstrb = xstrb(cmd, dtx);
    all_bytes = axi_bytes_touched(cmd);

    `uvm_info($sformatf("%m"), $sformatf("explicit_incr=%0d axsize=%0h axlen=%0d axburst=%0p smi_size=%0h total_size=%0h ax_addr=%p ax_wrap_base=%0h num slices=%0d  first slice=%0d",
					 my_explicit_incr, axsize(cmd), axi_len-1, axburst(cmd), smi_size, all_bytes, axaddr(cmd), axi_addr_wrap_base, num_slices, first_slice), UVM_HIGH)
    `uvm_info($sformatf("%m"), $sformatf("addr=%p smi_addr_intfsize_offset=%0h smi_base_intfsize_offset=%0h wrap_base=%0h wrap_top=%0h smi_addr_bus_offset=%0h xdata array size=%0d",
					 cmd.smi_addr, smi_addr_intfsize_offset, smi_base_intfsize_offset, smi_addr_wrap_base, smi_addr_wrap_top, smi_addr_bus_offset, xdata.size()), UVM_HIGH)
    for (int i=0 ; i < all_bytes ; i++ ) begin
      //fix for CONC-11224 : Even burst type is incr, we shouldn't  exceed the message size : code commented because is wrong and for our tracability
	//smi_flat_offset = (smi_addr_intfsize_offset + i) % CACHELINESIZE;
	//end else begin
	   if (i >= smi_size) begin
	      smi_flat_offset = (smi_addr_intfsize_offset + i) % CACHELINESIZE;
	   end else begin
	      smi_flat_offset = ((smi_addr_intfsize_offset + i) < smi_addr_wrap_top)?(smi_addr_intfsize_offset+i):(smi_addr_intfsize_offset+i-smi_addr_wrap_top+smi_addr_wrap_base);
           end
	//end

        if ( my_explicit_incr ) begin
	   axi_flat_offset = (smi_addr_bus_offset + i);
	end else begin
           if (my_narrow && cmd.isCmdNcRdMsg()) begin
	      if (cmd.smi_mpf1_burst_type == INCR) begin
		 axi_flat_offset = ((smi_addr_bus_offset + i) < axi_size) ? (smi_addr_bus_offset + i) : (smi_addr_bus_offset + i - axi_size);
	      end else begin
		 axi_flat_offset = (smi_addr_bus_offset + i);
	      end
	   end else begin
	      axi_flat_offset = (smi_addr_bus_offset + i);
	   end
	end
        axi_beat = axi_flat_offset/(my_narrow?axi_size:bus_size) - (my_narrow?first_slice:0);
        if (axi_beat >= axi_len) axi_beat = axi_beat - axi_len;

        axi_narrow_offset = ((cmd.smi_tof == SMI_TOF_CHI) || (cmd.smi_st == 0)) ? 'h0 : ( ((axi_flat_offset/axi_size) % num_slices) * axi_size ) ; 
        //if ((cmd.smi_tof == SMI_TOF_CHI) || (cmd.smi_mpf1_burst_type != INCR)) begin
        //CONC-14202
        if (axi_flat_offset < (axi_addr_wrap_base + smi_size)) begin
              axi_beat_offset = (axi_flat_offset % min(smi_size,bus_size)) + axi_addr_wrap_base;
        end else begin
              axi_beat_offset = ((axi_flat_offset - smi_size) % min(smi_size,bus_size)) + axi_addr_wrap_base ;
        end
       // end else begin
          // axi_beat_offset = (axi_flat_offset % bus_size);
        //end
        //copy
        xdata[axi_beat][(((axi_beat_offset + 1) * 8) - 1) -: 8] = smi_dat_flat[smi_flat_offset] ;
        `uvm_info($sformatf("%m"), $sformatf(" - %0d \t smi_flat_data[%0d]=%p to axi_flat_axsize[%0d]  narrow_offset %0d to axi[%0d][%0d] strb=%p size=%0h",
					     i, smi_flat_offset, smi_dat_flat[smi_flat_offset], axi_flat_offset, axi_narrow_offset, axi_beat, axi_beat_offset, m_xstrb[axi_beat][axi_beat_offset], all_bytes), UVM_DEBUG);
    end

<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi') || (obj.testBench == 'io_aiu') || (obj.testBench=="fsys")) { %>
`ifndef VCS
    `uvm_info($sformatf("%m"), $sformatf("smi_dp_dwid=%p", {<<{cmd.smi_dp_dwid}}), UVM_MEDIUM)
`endif // `ifndef VCS 
<% } else {%>
    `uvm_info($sformatf("%m"), $sformatf("smi_dp_dwid=%p", {<<{cmd.smi_dp_dwid}}), UVM_MEDIUM)
<% } %>

    `uvm_info($sformatf("%m"), $sformatf("smi_dat_flat=%p", smi_dat_flat), UVM_MEDIUM)
    `uvm_info($sformatf("%m"), $sformatf("template=%p", template), UVM_MEDIUM)
    `uvm_info($sformatf("%m"), $sformatf("-> exp_axi=%p", xdata), UVM_MEDIUM)
    
endfunction: xdata


//translate concerto byte enables to axi.
// don't care about bytes outside narrow rd.
// read behaves as if all bytes of axi frame enabled.
typedef axi_xstrb_t axi_xstrb_arr_t[];  //to enable array return
function static axi_xstrb_arr_t xstrb(smi_seq_item cmd, smi_seq_item dtx);
    bit[CACHELINESIZE-1     : 0] smi_be_flat;    //large enough to hold two copies of maximal size access.  little endian.
    bit[(CACHELINESIZE/8)-1 : 0] smi_dbad_flat;  //large enough to hold maximal size access.  little endian.

    int smi_addr_intfsize_offset;
    int smi_base_intfsize_offset;
    int smi_intfsize;
    int smi_size;   
    int	bus_size;
    int smi_addr_wrap_top;
    int smi_addr_wrap_base;
    int axi_addr_wrap_base;
   
    //
    bit	my_explicit_incr;
    bit	my_narrow;
    int axi_len;
    int axi_size;
    int smi_addr_bus_offset;
    //
    int num_slices;
    int first_slice;
    //
    int all_bytes;
    //
    int smi_flat_offset;
    int axi_flat_offset;
    int axi_beat;
    int axi_narrow_offset;
    int axi_beat_offset;
   
    //check inputs
    if(!cmd.isCmdMsg())  `uvm_error($sformatf("%m"), $sformatf("not a cmd"))
    if(!dtx.isDtrMsg() && !dtx.isDtwMsg())  `uvm_error($sformatf("%m"), $sformatf("not a data message type"))

    my_explicit_incr = explicit_incr(cmd);
    my_narrow        = narrow(cmd);
    axi_len = axlen(cmd) + 1;
   
    smi_size      = 2**cmd.smi_size;
    smi_intfsize  = 2**(cmd.smi_intfsize+3);
    bus_size      = (WXDATA/8);

    //read input data.
    `uvm_info($sformatf("%m"), $sformatf("cmd = %p", cmd), UVM_HIGH)
    `uvm_info($sformatf("%m"), $sformatf("smi addr =%p  smi intfsize=%0d  smi be=%p  smi dbad=%p", cmd.smi_addr, cmd.smi_intfsize, dtx.smi_dp_be, dtx.smi_dp_dbad), UVM_HIGH)
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi') || (obj.testBench == 'io_aiu') || (obj.testBench=="fsys")) { %>
`ifdef VCS
    if(dtx.smi_dp_be.size*wSmiDPbe==8)
      smi_be_flat = { { << wSmiDPbe {smi_be_flat_t0'(dtx.smi_dp_be)}} } ;
    else if(dtx.smi_dp_be.size*wSmiDPbe==16)
      smi_be_flat = { { << wSmiDPbe {smi_be_flat_t1'(dtx.smi_dp_be)}} } ;
    else if(dtx.smi_dp_be.size*wSmiDPbe==32)
      smi_be_flat = { { << wSmiDPbe {smi_be_flat_t2'(dtx.smi_dp_be)}} } ;
    else if(dtx.smi_dp_be.size*wSmiDPbe==64)
      smi_be_flat = { { << wSmiDPbe {smi_be_flat_t3'(dtx.smi_dp_be)}} } ;
    else if(dtx.smi_dp_be.size*wSmiDPbe==128)
      smi_be_flat = { { << wSmiDPbe {smi_be_flat_t4'(dtx.smi_dp_be)}} } ;
    else if(dtx.smi_dp_be.size*wSmiDPbe==256)
      smi_be_flat = { { << wSmiDPbe {smi_be_flat_t5'(dtx.smi_dp_be)}} } ;
    if(dtx.smi_dp_dbad.size*wSmiDPdbad==1)
      smi_dbad_flat = { { << wSmiDPdbad {smi_dbad_flat_t0'(dtx.smi_dp_dbad)}} } ;   //outer concat puts data in lsbs
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==2)
      smi_dbad_flat = { { << wSmiDPdbad {smi_dbad_flat_t1'(dtx.smi_dp_dbad)}} } ;   //outer concat puts data in lsbs
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==4)
      smi_dbad_flat = { { << wSmiDPdbad {smi_dbad_flat_t2'(dtx.smi_dp_dbad)}} } ;   //outer concat puts data in lsbs   
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==8)
      smi_dbad_flat = { { << wSmiDPdbad {smi_dbad_flat_t3'(dtx.smi_dp_dbad)}} } ;   //outer concat puts data in lsbs   
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==16)
      smi_dbad_flat = { { << wSmiDPdbad {smi_dbad_flat_t4'(dtx.smi_dp_dbad)}} } ;   //outer concat puts data in lsbs   
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==32)
      smi_dbad_flat = { { << wSmiDPdbad {smi_dbad_flat_t5'(dtx.smi_dp_dbad)}} } ;   //outer concat puts data in lsbs   
`elsif CDNS
    if(dtx.smi_dp_be.size*wSmiDPbe==8)
      smi_be_flat = smi_be_flat_t_0'( { << wSmiDPbe {smi_be_flat_t0'(dtx.smi_dp_be)}});
    else if(dtx.smi_dp_be.size*wSmiDPbe==16)
      smi_be_flat = smi_be_flat_t_1'( { << wSmiDPbe {smi_be_flat_t1'(dtx.smi_dp_be)}});
    else if(dtx.smi_dp_be.size*wSmiDPbe==32)
      smi_be_flat = smi_be_flat_t_2'( { << wSmiDPbe {smi_be_flat_t2'(dtx.smi_dp_be)}});
    else if(dtx.smi_dp_be.size*wSmiDPbe==64)
      smi_be_flat = smi_be_flat_t_3'( { << wSmiDPbe {smi_be_flat_t3'(dtx.smi_dp_be)}});
    else if(dtx.smi_dp_be.size*wSmiDPbe==128)
      smi_be_flat = smi_be_flat_t_4'( { << wSmiDPbe {smi_be_flat_t4'(dtx.smi_dp_be)}});
    else if(dtx.smi_dp_be.size*wSmiDPbe==256)
      smi_be_flat =smi_be_flat_t_5'( { << wSmiDPbe {smi_be_flat_t5'(dtx.smi_dp_be)}});
    if(dtx.smi_dp_dbad.size*wSmiDPdbad==1)
      smi_dbad_flat =smi_dbad_flat_t_0'( { << wSmiDPdbad {smi_dbad_flat_t0'(dtx.smi_dp_dbad)}});   //outer concat puts data in lsbs
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==2)
      smi_dbad_flat =smi_dbad_flat_t_1'( { << wSmiDPdbad {smi_dbad_flat_t1'(dtx.smi_dp_dbad)}});   //outer concat puts data in lsbs
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==4)
      smi_dbad_flat =smi_dbad_flat_t_2'( { << wSmiDPdbad {smi_dbad_flat_t2'(dtx.smi_dp_dbad)}});   //outer concat puts data in lsbs   
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==8)
      smi_dbad_flat =smi_dbad_flat_t_3'( { << wSmiDPdbad {smi_dbad_flat_t3'(dtx.smi_dp_dbad)}});   //outer concat puts data in lsbs   
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==16)
      smi_dbad_flat =smi_dbad_flat_t_4'( { << wSmiDPdbad {smi_dbad_flat_t4'(dtx.smi_dp_dbad)}});   //outer concat puts data in lsbs   
    else if(dtx.smi_dp_dbad.size*wSmiDPdbad==32)
      smi_dbad_flat =smi_dbad_flat_t_5'( { << wSmiDPdbad {smi_dbad_flat_t5'(dtx.smi_dp_dbad)}});   //outer concat puts data in lsbs   
`else // `ifdef VCS
    smi_be_flat ={{ << wSmiDPbe {dtx.smi_dp_be}}}  ;
    smi_dbad_flat ={{ << wSmiDPdbad {dtx.smi_dp_dbad}}}  ;   //outer concat puts data in lsbs   
`endif // `ifndef ... `else ... VCS 
<% } else {%>
    smi_be_flat = { { << wSmiDPbe {dtx.smi_dp_be}} } ;
    smi_dbad_flat = { { << wSmiDPdbad {dtx.smi_dp_dbad}} } ;   //outer concat puts data in lsbs   
<% } %>

    //combine concerto enables:
    // bad bytes disabled in axi access.
    // for(int i=0; i < max((2**cmd.smi_size),WXDATA/8); i++) begin
    for(int i=0; i < CACHELINESIZE; i++) begin
       if (smi_dbad_flat[i / 8]) smi_be_flat[i] = 0;
    end

    // check legality of smi_be. For CHI Device access, BE preceeding smi_size wrap base should be 0; BE passing smi_size should also be 0.
    if ((cmd.smi_tof == SMI_TOF_CHI) && cmd.smi_st && cmd.isCmdNcWrMsg()) begin
      for (int i=0; i<(cmd.smi_addr % smi_intfsize); i++) begin
         if (smi_be_flat[i] != 0) begin
           `uvm_error($sformatf("%m"), $sformatf("CHI BE error: ST=%0d ADDR=%p, INTFSIZE=%0h, BE[%0d] should be 0", cmd.smi_st, cmd.smi_addr, smi_intfsize, i))
	 end
      end
    end
	      
    // read out axi
    // default disable bytes outside the axi frame.  see axi4 spec fig. A3-14
    // For CHI accesses, the SMI address wrap is on 2**smi_size boundaries RD/WR operations (atomics are different!)
    // NOTES:
    // accesses range is: s=2**smi_size; st=(addr/s)*s; end=st+s
    // For smi: addresses are based on intfsize and start from address (critical word)
    // start_a = (addr%intf_size), wrap_a = (addr + i) = st + s or (addr - st + s).
    // for smi address, the wrap_a depends on s, bus, and intfsize. If s < bus, mod bus; s <= intfsize, mode intfsize, else mod s
    axi_size                 = 2**(my_narrow ? cmd.smi_mpf1_asize : axsize(cmd));
    smi_addr_wrap_base       = (cmd.smi_addr & (~(smi_size-1))) % smi_intfsize;
    smi_addr_wrap_top        = (smi_addr_wrap_base + smi_size);
    axi_addr_wrap_base       = (cmd.smi_addr & (~(smi_size-1))) % bus_size;
   
    smi_addr_intfsize_offset = cmd.smi_addr % smi_intfsize;
    smi_base_intfsize_offset = (bus_size < smi_intfsize) ? ( (cmd.smi_addr & (~(smi_size-1))) % smi_intfsize ) : 0;

    smi_addr_bus_offset      = (cmd.smi_addr % bus_size) ;

    num_slices  = ( my_narrow ) ? (bus_size / axi_size) : 1;
    first_slice = ( my_narrow ) ? ( (axaddr(cmd) % bus_size) / axi_size ) : 0;
    
    xstrb = new[axlen(cmd) + 1]; // default = {{`b0}} = disabled.
    all_bytes = axi_bytes_touched(cmd);

    `uvm_info($sformatf("%m"), $sformatf("explicit_incr=%0d narrow=%0d axsize=%0h axlen=%0d axburst=%0p smi_size=%0h total_size=%0h ax_addr=%p ax_wrap_base=%0h num slices=%0d  first slice=%0d",
					 my_explicit_incr, my_narrow, axsize(cmd), axi_len-1, axburst(cmd), smi_size, all_bytes, axaddr(cmd), axi_addr_wrap_base, num_slices, first_slice), UVM_HIGH)
    `uvm_info($sformatf("%m"), $sformatf("addr=%p smi_addr_intfsize_offset=%0h smi_base_intfsize_offset=%0h smi_addr_bus_offset=%0h",
					 cmd.smi_addr, smi_addr_intfsize_offset, smi_base_intfsize_offset, smi_addr_bus_offset), UVM_HIGH)

    for (int i=0 ; i < all_bytes ; i++ ) begin
        if ( my_explicit_incr ) begin
	   smi_flat_offset = (i+smi_addr_intfsize_offset);
	end else begin
	   smi_flat_offset = ((smi_addr_intfsize_offset + i) < smi_addr_wrap_top)?(smi_addr_intfsize_offset+i):(smi_addr_intfsize_offset+i-smi_addr_wrap_top+smi_addr_wrap_base);
	end // else: !if( my_explicit_incr )
       
        if ( my_explicit_incr ) begin
	   axi_flat_offset = (smi_addr_bus_offset + i);
	end else begin
           if (my_narrow && cmd.isCmdNcRdMsg()) begin
	      if (cmd.smi_mpf1_burst_type == INCR) begin
		 axi_flat_offset = ((smi_addr_bus_offset + i) < axi_size) ? (smi_addr_bus_offset + i) : (smi_addr_bus_offset + i - axi_size);
	      end else begin
		 axi_flat_offset = (smi_addr_bus_offset + i);
	      end
	   end else begin
	      axi_flat_offset = (smi_addr_bus_offset + i);
	   end
	end
	   
        //map directly into nonflat buffer
        // can't create variable length flat buffer in sv
        // xstrb_flat[axi_flat_offset] = smi_be_flat[smi_flat_offset] ;
        // axi_beat = (axi_flat_offset / max(axi_size,bus_size));
        axi_beat = (axi_flat_offset / (my_narrow?axi_size:bus_size)) - (my_narrow?first_slice:0);
        if (axi_beat >= axi_len) axi_beat = axi_beat - axi_len;
       
        axi_narrow_offset = ((cmd.smi_tof == SMI_TOF_CHI) || (cmd.smi_st == 0)) ? 'h0 : ( ((axi_flat_offset/axi_size) % num_slices) * axi_size ) ; 
        //axi_beat_offset   = (axi_flat_offset % bus_size) ;
        //if ((cmd.smi_tof == SMI_TOF_CHI) || (cmd.smi_mpf1_burst_type != INCR)) begin
        //CONC-14202
        if (axi_flat_offset < (axi_addr_wrap_base + smi_size)) begin
              axi_beat_offset = (axi_flat_offset % min(smi_size,bus_size)) + axi_addr_wrap_base;
        end else begin
              axi_beat_offset = ((axi_flat_offset - smi_size) % min(smi_size,bus_size)) + axi_addr_wrap_base ;
        end
        //end else begin
          // axi_beat_offset = (axi_flat_offset % bus_size);
        //end
       //copy
        xstrb[axi_beat][axi_beat_offset] = smi_be_flat[smi_flat_offset] ;
        `uvm_info($sformatf("%m"), $sformatf("axi_flat_offset:%0h smi_size:%0h bus_size:%0h axi_addr_wrap_base:%0h axi_beat_offset:%0h", axi_flat_offset, smi_size, bus_size, axi_addr_wrap_base, axi_beat_offset), UVM_DEBUG)
        `uvm_info($sformatf("%m"), $sformatf(" - %0d: smi_dbad_flat[%0d]=%0d smi_flat_xstrb[%0d]=%p to axi_flat_xstrb[%0d] narrow_offset %0d to axi[%0d][%0d]",
                                             i, smi_flat_offset/8, smi_dbad_flat[smi_flat_offset/8], smi_flat_offset, smi_be_flat[smi_flat_offset], axi_flat_offset, axi_narrow_offset, axi_beat, axi_beat_offset), UVM_DEBUG);
    end

    `uvm_info($sformatf("%m"), $sformatf("dbad_flat=%p: be_flat=%p -> exp_axi=%p", smi_dbad_flat, smi_be_flat, xstrb), UVM_MEDIUM)

endfunction : xstrb
//------------------------------------------------------------------------------------------------


