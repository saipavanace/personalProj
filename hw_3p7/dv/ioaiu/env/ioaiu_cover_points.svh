    <%
    var cohIds = [];
   
    obj.AiuInfo.forEach(function(bundle, indx) {
	     if((bundle.BlockId != obj.BlockId) &&
	         ((bundle.fnNativeInterface == "ACE") ||
	         (bundle.fnNativeInterface == "CHI") ||
	         (bundle.fnNativeInterface == "CHI-A") ||
	         (bundle.fnNativeInterface == "CHI-B") ||
	         ((bundle.fnNativeInterface == "AXI4" || bundle.fnNativeInterface == "AXI5") && bundle.useCache))) {
	             cohIds.push(indx);
	         }
        });%>
`define COVER_POINT_RA_BURST_TYPE \
burst_type : coverpoint arburst { \
   bins incr_burst   = {AXIINCR}; \
   bins wrap_burst   = {AXIWRAP}; \
   ignore_bins ignore_unsupported_burst_type = {AXIFIXED}; \
   }

`define COVER_POINT_RA_BURST_LENGTH \
burst_length: coverpoint arlen { \
   bins wrap_arlen[] = {1,3,7,15} iff(arburst==AXIWRAP); \
   bins incr_arlen[] = {[0:15]} iff(arburst==AXIINCR); \
   bins incr_arlen_16_47   = {[16:47]} iff(arburst==AXIINCR); \
   bins incr_arlen_48_79   = {[48:79]} iff(arburst==AXIINCR); \
   bins incr_arlen_80_126  = {[80:126]} iff(arburst==AXIINCR); \
   bins incr_arlen_127     = {127} iff(arburst==AXIINCR); \
   bins incr_arlen_128_143 = {[128:143]} iff(arburst==AXIINCR); \
   bins incr_arlen_144_175 = {[144:175]} iff(arburst==AXIINCR); \
   bins incr_arlen_176_207 = {[176:207]} iff(arburst==AXIINCR); \
   bins incr_arlen_208_254 = {[208:254]} iff(arburst==AXIINCR); \
   bins incr_arlen_255 = {255} iff(arburst==AXIINCR); \
   ignore_bins  cross_4KB_boundary = {[(4096/<%=obj.wData/8%> - 1) : 255]};\
   }

`define COVER_POINT_RA_BURST_SIZE \
burst_size: coverpoint arsize { \
   bins arsize[] = {[0:<%=Math.ceil(Math.log2(obj.wData/8))%>]}; \
   }

//`define COVER_POINT_RA_ARID_MATCH \
//Match_ARID: coverpoint arid_matched { \
//   bins AridMatch = {1}; \
//   }
//
//`define COVER_POINT_RA_ARADDR_MATCH \
//Match_ARADDR: coverpoint araddr_matched { \
//   bins AraddrMatch = {1}; \
//   }

`define COVER_POINT_RA_CACHELINE_ACCESS \
cacheline_access: coverpoint rdCachelineAccess { \
   bins ReadMultiple = {3}; \
   bins ReadFull = {2}; \
   bins ReadPartial = {1}; \
   }

`define COVER_POINT_RA_WEIRD_WRAP \
weird_wrap_case: coverpoint arWeirdWrap { \
   bins weird_wrap = {1}; \
   }

`define CROSS_RA_BURST_TYPE_CACHELINE_ACCESS \
burst_typeXcacheline_access: cross burst_type, cacheline_access;

`define CROSS_RA_BURST_LENGTH_SIZE_TYPE \
burst_typeXburst_lengthXburst_size: cross burst_size, burst_length{\
   ignore_bins narrow_txn_len_0 = !binsof(burst_size) intersect{<%=Math.ceil(Math.log2(obj.wData/8))%>} && !binsof(burst_length) intersect{0} ;\
}

`define COVER_POINT_WA_BURST_TYPE \
burst_type : coverpoint awburst { \
   bins fixed_burst  = {AXIFIXED}; \
   bins incr_burst   = {AXIINCR}; \
   bins wrap_burst   = {AXIWRAP}; \
   ignore_bins ignore_unsupported_burst_type = {AXIFIXED}; \
   }

`define COVER_POINT_WA_BURST_LENGTH \
burst_length: coverpoint awlen { \
   bins wrap_awlen[] = {1,3,7,15} iff(awburst==AXIWRAP); \
   bins incr_awlen[] = {[0:15]} iff(awburst==AXIINCR); \
   bins incr_awlen_16_47   = {[16:47]} iff(awburst==AXIINCR); \
   bins incr_awlen_48_79   = {[48:79]} iff(awburst==AXIINCR); \
   bins incr_awlen_80_126  = {[80:126]} iff(awburst==AXIINCR); \
   bins incr_awlen_127     = {127} iff(awburst==AXIINCR); \
   bins incr_awlen_128_143 = {[128:143]} iff(awburst==AXIINCR); \
   bins incr_awlen_144_175 = {[144:175]} iff(awburst==AXIINCR); \
   bins incr_awlen_176_207 = {[176:207]} iff(awburst==AXIINCR); \
   bins incr_awlen_208_254 = {[208:254]} iff(awburst==AXIINCR); \
   bins incr_awlen_255 = {255} iff(awburst==AXIINCR); \
   ignore_bins  cross_4KB_boundary = {[(4096/<%=obj.wData/8%> - 1) : 255]};\
   }

`define COVER_POINT_WA_BURST_SIZE \
burst_size: coverpoint awsize { \
   bins awsize[] = {[0:<%=Math.ceil(Math.log2(obj.wData/8))%>]}; \
   }

//`define COVER_POINT_WA_AWID_MATCH \
//Match_AWID: coverpoint awid_matched { \
//   bins AwidMatch = {1}; \
//   }
//
//`define COVER_POINT_WA_AWADDR_MATCH \
//Match_AWADDR: coverpoint awaddr_matched { \
//   bins AraddrMatch = {1}; \
//   }

`define COVER_POINT_WA_CACHELINE_ACCESS \
cacheline_access: coverpoint wrCachelineAccess { \
   bins WriteMultiple = {3}; \
   bins WriteFull = {2}; \
   bins WritePartial = {1}; \
   }

`define COVER_POINT_WA_WEIRD_WRAP \
weird_wrap_case: coverpoint awWeirdWrap { \
   bins weird_wrap = {1}; \
}

`define CROSS_WA_BURST_TYPE_CACHELINE_ACCESS \
burst_typeXcacheline_access: cross burst_type, cacheline_access;

`define CROSS_WA_BURST_LENGTH_SIZE_TYPE \
burst_typeXburst_lengthXburst_size: cross burst_size, burst_length{\
   ignore_bins narrow_txn_len_0 = !binsof(burst_size) intersect{<%=Math.ceil(Math.log2(obj.wData/8))%>} && !binsof(burst_length) intersect{0} ;\
}
