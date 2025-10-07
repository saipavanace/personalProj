////////////////////////////////////////////////////////////////////////////////
//
// This file contains functions which are useful for Ncore 3.0 units
//
////////////////////////////////////////////////////////////////////////////////
<%const chipletObj = obj.lib.getAllChipletRefs();%>

<% if (chipletObj[0].useResiliency) { %>
 function bit[127:0] calcParity(bit[1023:0] data, int len);
     byte q[128];

     <%for(var i = 0; i< 128; i++) {%>
	 q[<%=i%>] = data[<%=i*8+7%>:<%=i*8%>];
     <%}%>

     calcParity = 128'b0;

     <%for(var i = 0; i< 128; i++) {%>
       calcParity[<%=i%>] = (^q[<%=i%>]);
     <%}%>

 endfunction: calcParity

 function bit[127:0] checkSECDED_128B(bit[1023:0] data, int N);

    bit[127:0] q[8];

    <%for(var i = 0; i< 8; i++) {%>
	q[<%=i%>] = data[<%=i*128+127%>:<%=i*128%>];
    <%}%>

    checkSECDED_128B = 128'b0;

    // YRAMASAMY FIX: i<16 doesnt make sense when there is only q[8]!
    <%for(var i=0; i < 8; i++) {%>
	checkSECDED_128B[<%=(i*8+7)%>:<%=(i*8)%>] = checkSECDED_each128(q[<%=i%>], N);
	//$display("\nDEBUG_checksecded_data-%0d - each64_data=0x%x checkSECDED[<%=(i*8+7)%>:<%=(i*8)%>] = 0x%x \n", <%=i%>, q[<%=i%>], checkSECDED[<%=(i*8+7)%>:<%=(i*8)%>] );
    <%}%>

 endfunction: checkSECDED_128B

 // In these functions, N is used to define the number of bits on which SECDED bits need to be calculated
 // For example, in SECDED128, N should be 128
 // TODO: the below function should be used only when SECDED128 protection applies
 function bit[127:0] genSECDED_128B(bit[1023:0] data, int N);

    genSECDED_128B = checkSECDED_128B(data, N);

 endfunction: genSECDED_128B


 function bit[63:0] checkSECDED_64B(bit[1023:0] data, int N);

    bit[63:0] q[16];

    <%for(var i = 0; i< 16; i++) {%>
	q[<%=i%>] = data[<%=i*64+63%>:<%=i*64%>];
    <%}%>

    checkSECDED_64B = 64'b0;

    <%for(var i=0; i< 8; i++) {%>
	checkSECDED_64B[<%=(i*8+7)%>:<%=(i*8)%>] = checkSECDED_each64(q[<%=i%>], N);
	//$display("\nDEBUG_checksecded_data-%0d - each64_data=0x%x checkSECDED[<%=(i*8+7)%>:<%=(i*8)%>] = 0x%x \n", <%=i%>, q[<%=i%>], checkSECDED[<%=(i*8+7)%>:<%=(i*8)%>] );
    <%}%>

 endfunction: checkSECDED_64B

 // TODO: the below function should be used only when SECDED64 protection applies
 function bit[127:0] genSECDED_64B(bit[1023:0] data, int N);

    genSECDED_64B = checkSECDED_64B(data, N);

 endfunction: genSECDED_64B


 function smi_ndp_protection_t checkSECDED_each64(bit[63:0] data, int N);
   checkSECDED_each64 = checkSECDED_N(data, N);
 endfunction: checkSECDED_each64

 function smi_ndp_protection_t checkSECDED_each128(bit[WSMINDP-1:0] data, int N);
   checkSECDED_each128 = checkSECDED_N(data, N);
 endfunction: checkSECDED_each128

//function generates the expected SECDED for N-width data; second argument N specifies the width of the data to calculate SECDED on
//Maximum input data width now supported is 247 bits with 9-bits of protection
 function automatic smi_ndp_protection_t checkSECDED_N(smi_ndp_bit_t data, smi_ndp_len_bit_t N, int parity_width=0);
    int N1;
    bit [256-1:0] stretched_vector;
    int num_of_parity = 0;
    int pointer = 0;
    int offset = 1;
    bit Generator_Matrix[0:wSmiNdpProt-1][0:256-1];
    smi_ndp_len_bit_t    fill_width;
    smi_ndp_protection_t ecc_saved;

    `uvm_info($sformatf("%m"), $sformatf("checkSECDED: data_in:%p pld_len:%0d check_bit:%0d", data, N, parity_width), UVM_MEDIUM)
    assert(WSMINDP < 248) else begin
       `uvm_error($sformatf("%m"), $sformatf("ECC input data size %0d is larger than too large for ECC bits %0d", WSMINDP, wSmiNdpProt))
    end
    for (int i=N+parity_width; i<256; i++) begin
        data[i] = 0;
    end
    `uvm_info($sformatf("%m"), $sformatf("checkSECDED: data_in (cleanedup):%p pld_len:%0d check_bit:%0d", data, N, parity_width), UVM_MEDIUM)
    checkSECDED_N = {wSmiNdpProt{1'b0}};

    Generator_Matrix[0] = '{1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0};
    Generator_Matrix[1] = '{0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0};
    Generator_Matrix[2] = '{0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0};
    Generator_Matrix[3] = '{0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0};
    Generator_Matrix[4] = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0};
    Generator_Matrix[5] = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0};
    Generator_Matrix[6] = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0};
    Generator_Matrix[7] = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0};
<% if (chipletObj[0].Widths.Physical.wNdpBody > 110) { %>
    Generator_Matrix[8] = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
<% } %>

    stretched_vector = {256{1'b0}};

    //SECDED is padding invariant, so we compute on full width every time:  SECDED(m) == SECDED({n'b0, m})
    N1 = N;
    while (N1 > 0) begin
	fill_width = ((2**num_of_parity) - 1);
	N1 -= fill_width;
	
	for (int ii=0; ii < fill_width; ii++) begin
	    stretched_vector[offset] = (pointer < N) ? data[pointer] : 1'b0;
//            `uvm_info($sformatf("ECC ENC"),$sformatf("S[%03d]=D[%03d](%0d)", offset, pointer, stretched_vector[offset]), UVM_DEBUG)
	    pointer++;
	    offset++;
	end

        if (num_of_parity == 0) begin
           ecc_saved[num_of_parity]   = data[N+num_of_parity];
           stretched_vector[offset-1] = data[N+num_of_parity];
//          `uvm_info($sformatf("ECC ENC"),$sformatf("S[%03d]=P[%03d](%0d)", offset-1, num_of_parity, stretched_vector[offset-1]), UVM_DEBUG)
        end

        ecc_saved[num_of_parity]   = data[N+num_of_parity+1];
        if (N1 > 0) begin
            stretched_vector[offset] = data[N+num_of_parity+1];
//           `uvm_info($sformatf("ECC ENC"),$sformatf("S[%03d]=P[%03d](%0d)", offset, num_of_parity+1, stretched_vector[offset]), UVM_DEBUG)
        end

	offset++;
	num_of_parity++;
   end

   `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: num_parity=0x%0d stretched_vector=0x%0h", num_of_parity, stretched_vector), UVM_DEBUG)
   for(int jj=0; jj<num_of_parity; jj++) begin
     for(int kk=0; kk<(2**num_of_parity); kk++) begin
	 checkSECDED_N[jj] ^= ( stretched_vector[kk] & Generator_Matrix[jj][kk] ) ;
//        `uvm_info($sformatf("ECC ENC"), $sformatf("C[%2d]=%0d, S[%3d]=%0d, G=%0d", jj, checkSECDED_N[jj], kk, stretched_vector[kk], Generator_Matrix[jj][kk]), UVM_DEBUG)
     end
//     `uvm_info($sformatf("ECC ENC"), $sformatf("C[%2d]=%0d", jj, checkSECDED_N[jj]), UVM_DEBUG)
   end

   `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: checkbits=0x%0h (incoming=0x%0h) stretched_vector=0x%0h: parity=%0d", checkSECDED_N, ecc_saved, stretched_vector, ^{checkSECDED_N&((1<<num_of_parity)-1), stretched_vector}), UVM_DEBUG)

   num_of_parity++;
   checkSECDED_N[num_of_parity-1] = ^{checkSECDED_N&((1<<num_of_parity-1)-1), stretched_vector, (parity_width > 0) ? data[N+parity_width-1] : 1'b0};
   `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: input data=0x%x (pld=0x%0x), data bits=%0d, calculated checkSECDED_N=0x%x, num_parity=%0d",
                                        data, data&((1<<N)-1), N, checkSECDED_N, num_of_parity), UVM_MEDIUM)
 endfunction: checkSECDED_N

// Generate Even even parity for input data
function bit checkPARITY_N(bit[WSMINDP-1:0] data, int N);
   int N1;
   //`uvm_info($sformatf("%m"), $sformatf("PARITY DEBUG1: WSMINDP=%0d N=%0d data=0x%0h", WSMINDP, N, data), UVM_DEBUG)

   for (int i=N; i<WSMINDP; i++) data[i] = 1'b0;  // clear bits above size

   //`uvm_info($sformatf("%m"), $sformatf("PARITY DEBUG2: data=0x%0h ndp_prot:%b", data, (^data)), UVM_DEBUG)
   return (^data);
endfunction : checkPARITY_N
   
// based on msg_type, returns either the length of full NDP (with NDP_PROT), or without NCP_PROT
function automatic int get_ndp_len(smi_msg_type_bit_t msg_type, bit full=1);
   int len;
   eMsgCMD	 eCmdMsg;
   eMsgCCmdRsp	 eCmdRsp;
   eMsgNCCmdRsp	 eNcCmdRsp;
   eMsgSNP	 eSnpMsg;
   eMsgSnpRsp	 eSnpRsp;
   eMsgMRD	 eMrdMsg;
   eMsgMrdRsp	 eMrdRsp;
   eMsgSTR	 eStrMsg;
   eMsgStrRsp	 eStrRsp;
   eMsgDTR	 eDtrMsg;
   eMsgDtrRsp	 eDtrRsp;
   eMsgDTW	 eDtwMsg;
   eMsgDTWMrgMRD eDtwMrgMsg;
   eMsgDtwDbgReq eDtwDbgMsg;
   eMsgDtwDbgRsp eDtwDbgRsp;
   eMsgDtwRsp	 eDtwRsp;
   eMsgUPD	 eUpdMsg;
   eMsgUpdRsp	 eUpdRsp;
   eMsgRBReq	 eRbMsg;
   eMsgRBRsp	 eRbRsp;
   eMsgRBUsed	 eRbuMsg;
   eMsgRBUseRsp	 eRbuRsp;
   eMsgCmpRsp	 eCmpRsp;
   eMsgSysReq    eSysReq;
   eMsgSysRsp    eSysRsp;

   if	   (msg_type inside {[eCmdMsg.first():eCmdMsg.last()]})		  len = (full ? w_CMD_REQ_NDP	: CMD_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eCmdRsp.first():eCmdRsp.last()]})		  len = (full ? w_C_CMD_RSP_NDP : C_CMD_RSP_NDP_PROT_LSB );
   else if (msg_type inside {[eNcCmdRsp.first():eNcCmdRsp.last()]})	  len = (full ? w_NC_CMD_RSP_NDP: NC_CMD_RSP_NDP_PROT_LSB);
   else if (msg_type inside {[eSnpMsg.first():eSnpMsg.last()]})		  len = (full ? w_SNP_REQ_NDP	: SNP_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eSnpRsp.first():eSnpRsp.last()]})		  len = (full ? w_SNP_RSP_NDP	: SNP_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eMrdMsg.first():eMrdMsg.last()]})		  len = (full ? w_MRD_REQ_NDP	: MRD_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eMrdRsp.first():eMrdRsp.last()]})		  len = (full ? w_MRD_RSP_NDP	: MRD_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eStrMsg.first():eStrMsg.last()]})		  len = (full ? w_STR_REQ_NDP	: STR_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eStrRsp.first():eStrRsp.last()]})		  len = (full ? w_STR_RSP_NDP	: STR_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eDtrMsg.first():eDtrMsg.last()]})		  len = (full ? w_DTR_REQ_NDP	: DTR_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eDtrRsp.first():eDtrRsp.last()]})		  len = (full ? w_DTR_RSP_NDP	: DTR_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eDtwMsg.first():eDtwMsg.last()]})		  len = (full ? w_DTW_REQ_NDP	: DTW_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eDtwMrgMsg.first():eDtwMrgMsg.last()]})	  len = (full ? w_DTW_REQ_NDP	: DTW_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eDtwRsp.first():eDtwRsp.last()]})		  len = (full ? w_DTW_RSP_NDP	: DTW_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eDtwDbgMsg.first():eDtwDbgMsg.last()]})	  len = (full ? w_DTW_DBG_REQ_NDP: DTW_DBG_REQ_NDP_PROT_LSB );
   else if (msg_type inside {[eDtwDbgRsp.first():eDtwDbgRsp.last()]})	  len = (full ? w_DTW_DBG_RSP_NDP: DTW_DBG_RSP_NDP_PROT_LSB );
   else if (msg_type inside {[eUpdMsg.first():eUpdMsg.last()]})		  len = (full ? w_UPD_REQ_NDP	: UPD_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eUpdRsp.first():eUpdRsp.last()]})		  len = (full ? w_UPD_RSP_NDP	: UPD_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eRbMsg.first():eRbMsg.last()]})		  len = (full ? w_RB_REQ_NDP	: RB_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eRbRsp.first():eRbRsp.last()]})		  len = (full ? w_RB_RSP_NDP	: RB_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eUpdMsg.first():eUpdMsg.last()]})		  len = (full ? w_UPD_REQ_NDP	: UPD_REQ_NDP_PROT_LSB	 );
   else if (msg_type inside {[eUpdRsp.first():eUpdRsp.last()]})		  len = (full ? w_UPD_RSP_NDP	: UPD_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eRbuMsg.first():eRbuMsg.last()]})		  len = (full ? w_RBUSE_REQ_NDP : RBUSE_REQ_NDP_PROT_LSB );
   else if (msg_type inside {[eRbuRsp.first():eRbuRsp.last()]})		  len = (full ? w_RBUSE_RSP_NDP : RBUSE_RSP_NDP_PROT_LSB );
   else if (msg_type inside {[eCmpRsp.first():eCmpRsp.last()]})		  len = (full ? w_CMP_RSP_NDP	: CMP_RSP_NDP_PROT_LSB	 );
   else if (msg_type inside {[eSysReq.first():eSysReq.last()]})           len = (full ? w_SYS_REQ_NDP   : SYS_REQ_NDP_PROT_LSB   );
   else if (msg_type inside {[eSysRsp.first():eSysRsp.last()]})           len = (full ? w_SYS_RSP_NDP   : SYS_RSP_NDP_PROT_LSB   );
   else begin
     bit [2:0] inj_cntl = $value$plusargs("inj_cntl=%0d", inj_cntl);
     if ($test$plusargs("smi_hdr_err_inj")
         && ($test$plusargs("inject_smi_uncorr_error") ||
             (<% if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType === 'parity') { %> (inj_cntl[2] == 1)
              <% } else if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType === 'ecc') {%> (inj_cntl[1] == 1)
              <% } else { %> 0 <% } %> )
            )
        ) begin
       `uvm_warning($sformatf("%m"), $sformatf("GET_NDP_LEN: Unexpected MSG_TYPE?"))
     end else
     begin
      `uvm_error($sformatf("%m"), $sformatf("GET_NDP_LEN: Unexpected MSG_TYPE=%0h", msg_type))
     end
   end
//   `uvm_info($sformatf("%m"), $sformatf("GET_NDP_LEN: msg_type=%0h len=%0h", msg_type, len), UVM_DEBUG)
   return len;
endfunction : get_ndp_len
			    
function automatic smi_ndp_bit_t inject_smi_ndp_error(smi_msg_type_bit_t msg_type, smi_ndp_bit_t ndp_in, bit[2:0] inj_cntl);
   smi_ndp_bit_t    ndp_out;
   int		 len; // derived based on message type
   bit		 inj_en;
   eMsgCMD	 eCmdMsg;
   eMsgCCmdRsp	 eCmdRsp;
   eMsgNCCmdRsp	 eNcCmdRsp;
   eMsgSNP	 eSnpMsg;
   eMsgSnpRsp	 eSnpRsp;
   eMsgMRD	 eMrdMsg;
   eMsgMrdRsp	 eMrdRsp;
   eMsgSTR	 eStrMsg;
   eMsgStrRsp	 eStrRsp;
   eMsgDTR	 eDtrMsg;
   eMsgDtrRsp	 eDtrRsp;
   eMsgDTW	 eDtwMsg;
   eMsgDTWMrgMRD eDtwMrgMsg;
   eMsgDtwRsp	 eDtwRsp;
   eMsgDtwDbgReq eDtwDbgMsg;
   eMsgDtwDbgRsp eDtwDbgRsp;
   eMsgUPD	 eUpdMsg;
   eMsgUpdRsp	 eUpdRsp;
   eMsgRBReq	 eRbMsg;
   eMsgRBRsp	 eRbRsp;
   eMsgRBUsed	 eRbuMsg;
   eMsgRBUseRsp	 eRbuRsp;
   eMsgCmpRsp	 eCmpRsp;
   eMsgSysReq    eSysReq;
   eMsgSysRsp    eSysRsp;
   inj_en	  = 0;
   `uvm_info($sformatf("%m"), $sformatf("Inject: inj_cntl=%0h msg_type=%0h NDP=%p", inj_cntl, msg_type, ndp_in), UVM_HIGH)
   if ((inj_cntl != 0) && ("<%=chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType%>" == "none")) begin
      `uvm_info($sformatf("%m"), $sformatf("Inject: inj_cntl set to 0 since protection type is NONE"), UVM_DEBUG)
      inj_cntl = 0;
   end
   len = get_ndp_len(msg_type);
   if ((inj_cntl != 0) || ($test$plusargs("cmd_req_err_inj") && (msg_type inside {[eCmdMsg.first():eCmdMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: CmdReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("ccmd_rsp_err_inj") && (msg_type inside {[eCmdRsp.first():eCmdRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: C-CmdRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("nccmd_rsp_err_inj") && (msg_type inside {[eNcCmdRsp.first():eNcCmdRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: NC-CmdRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("snp_req_err_inj") && (msg_type inside {[eSnpMsg.first():eSnpMsg.last()]}))) begin	
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: SnpReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("snp_rsp_err_inj") && (msg_type inside {[eSnpRsp.first():eSnpRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: SnpRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("mrd_req_err_inj") && (msg_type inside {[eMrdMsg.first():eMrdMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: MrdReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("mrd_rsp_err_inj") && (msg_type inside {[eMrdRsp.first():eMrdRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: MrdRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("str_req_err_inj") && (msg_type inside {[eStrMsg.first():eStrMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: StrReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("str_rsp_err_inj") && (msg_type inside {[eStrRsp.first():eStrRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: StrRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("dtr_req_err_inj") && (msg_type inside {[eDtrMsg.first():eDtrMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: DtrReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("dtr_rsp_err_inj") && (msg_type inside {[eDtrRsp.first():eDtrRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: DtrRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("dtw_req_err_inj") && (msg_type inside {[eDtwMsg.first():eDtwMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: DtwReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("dtw_dbg_req_err_inj") && (msg_type inside {[eDtwDbgMsg.first():eDtwDbgMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: DtwDbgReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("dtwmrg_req_err_inj") && (msg_type inside {[eDtwMrgMsg.first():eDtwMrgMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: DtwMrgMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("dtw_rsp_err_inj") && (msg_type inside {[eDtwRsp.first():eDtwRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: DtwRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("dtw_dbg_rsp_err_inj") && (msg_type inside {[eDtwDbgRsp.first():eDtwDbgRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: DtwDbgRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("upd_req_err_inj") && (msg_type inside {[eUpdMsg.first():eUpdMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: UpdReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("upd_rsp_err_inj") && (msg_type inside {[eUpdRsp.first():eUpdRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: UpdRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("rbr_req_err_inj") && (msg_type inside {[eRbMsg.first():eRbMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: RbReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("rbr_rsp_err_inj") && (msg_type inside {[eRbRsp.first():eRbRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: RbRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("rbu_req_err_inj") && (msg_type inside {[eRbuMsg.first():eRbuMsg.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: RbuReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("rbu_rsp_err_inj") && (msg_type inside {[eRbuRsp.first():eRbuRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: RbuRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("cmp_rsp_err_inj") && (msg_type inside {[eCmpRsp.first():eCmpRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: CmprspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("sys_req_err_inj") && (msg_type inside {[eSysReq.first():eSysReq.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: SysReqMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if ((inj_cntl != 0) || ($test$plusargs("sys_rsp_err_inj") && (msg_type inside {[eSysRsp.first():eSysRsp.last()]}))) begin
      inj_en = 1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: SysRspMsg (%0h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end else if (inj_cntl != 0) begin
          // no specific msg_type
       inj_en =1;
      `uvm_info($sformatf("%m"), $sformatf("Inject: Msg(0x%h) NDP len=%0d", msg_type, len), UVM_DEBUG)
   end
   if (inj_en) begin
      for (int i=len; i<WSMINDP; i++) ndp_in[i] = 1'b0;
      ndp_out = smi_inject_error(msg_type, ndp_in, get_ndp_len(msg_type, 0), len, inj_cntl);
   end else begin
      ndp_out = ndp_in;
   end
   `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: NDP error injection: inj_cntl=%0h en=%0d msg_type=%0h len=%0d ndp_in=%p ndp_out=%p",
					inj_cntl, inj_en, msg_type, len, ndp_in, ndp_out), UVM_MEDIUM)
   return (ndp_out);
endfunction : inject_smi_ndp_error

// This function injects error at random location to dat_in. As such it is used for hdr and dp injection.
// For NDP errors, need to invoke inject_smi_ndp_error as the lengths depends on message types.
function automatic smi_ndp_bit_t smi_inject_error(smi_msg_type_bit_t msg_type, smi_ndp_bit_t dat_in, int pld_len, int full_len, bit[2:0] inj_cntl); // inj_cntl[2]: parity, inj_cntl[1] uncor, inj_cntl[0] corr
   integer unsigned err1_loc, err2_loc;
   static int unsigned ndp_err1_loc, ndp_err2_loc;
   smi_ndp_bit_t inj_mask;

   inj_mask = 'b0;
   if (inj_cntl == 3'b000) begin
      return dat_in;
   end

   if($test$plusargs("check_hdr_msg_type")) begin
     if(!check_err_inj_msg_type(msg_type)) begin
       `uvm_info($sformatf("%m"), $sformatf("Skipping error injection as msg_type(%0h) not match", msg_type), UVM_DEBUG)
       return dat_in;
     end else begin
       `uvm_info($sformatf("%m"), $sformatf("Will inject error as msg_type(%0h) match", msg_type), UVM_DEBUG)
     end
   end

<% if ((chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType === 'parity') || (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType === 'ecc')) { %>
<% if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType === 'parity') { %>
   if ($test$plusargs("inject_smi_uncorr_error") || (inj_cntl[2:0] == 3'b100)) begin                                                                                
<% } else if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType === 'ecc') { %>
   if (($test$plusargs("inject_smi_corr_error") || (inj_cntl[0] === 1'b1)) || ($test$plusargs("inject_smi_uncorr_error") || (inj_cntl[1] === 1'b1))) begin
<% } %>
      if ($test$plusargs("inject_smi_checkbits_only")) begin
          assert(std::randomize(err1_loc) with { err1_loc inside {[pld_len:full_len-1]};});
      end else if ($test$plusargs("inject_smi_databits_only")) begin
          assert(std::randomize(err1_loc) with { err1_loc inside {[0:pld_len-1]};});
      end else begin
          assert(std::randomize(err1_loc) with { err1_loc inside {[0:full_len-1]};});
      end
      inj_mask = 1 << err1_loc;
      if($test$plusargs("smi_ndp_err_inj")) begin
         ndp_err1_loc=err1_loc;
       end
      `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: Inject SMI %s Error at %0d. pld_len=%0d full_len=%0d (pld=%p)",
                                           ((!$test$plusargs("inject_smi_uncorr_error") || (inj_cntl[0] == 1'b1))?"correctable":"uncorrectable"),
                                           err1_loc, pld_len, full_len, dat_in), UVM_MEDIUM)
   end
   // No second bit error injection for parity case
<% if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType === 'ecc') { %>
   if ($test$plusargs("inject_smi_uncorr_error") || inj_cntl[1] == 1'b1) begin
      if ($test$plusargs("inject_smi_checkbits_only")) begin
          assert(std::randomize(err2_loc) with { err2_loc inside {[pld_len:full_len-1]}; err2_loc != err1_loc;});
      end else if ($test$plusargs("inject_smi_databits_only")) begin
          assert(std::randomize(err2_loc) with { err2_loc inside {[0:pld_len-1]}; err2_loc != err1_loc;});
      end else begin
          assert(std::randomize(err2_loc) with { err2_loc inside {[0:full_len-1]}; err2_loc != err1_loc;});
      end
      if($test$plusargs("smi_ndp_err_inj")) begin
         ndp_err2_loc=err2_loc;
      end
      inj_mask |= (1 << err2_loc);
      `uvm_info($sformatf("%m"), $sformatf("ndp_err1_loc=%0d,ndp_err2_loc=%0d",ndp_err1_loc,ndp_err2_loc), UVM_DEBUG)
      `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: Inject SMI Un-correctable Error at %0d and %0d. pld_len=%0d full_len=%0d",
                                           err1_loc, err2_loc, pld_len, full_len), UVM_MEDIUM)
   end
<% } %>
<% } %>

   if (inj_mask != 'h0) begin
        `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: Inject Mask %p. DI=%0p, DO=%0p", inj_mask, dat_in, dat_in^inj_mask), UVM_NONE)
   end
   `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG ERRINJ: len %0d Inject Mask %p. DI=%0p, DO=%0p", full_len, inj_mask, dat_in, dat_in^inj_mask), UVM_HIGH)
   return (dat_in ^ inj_mask);
endfunction : smi_inject_error

function automatic smi_err_class_t smi_check_err(smi_ndp_bit_t dat_in, int pld_len, int full_len, output smi_ndp_bit_t dat_out);
    smi_ndp_protection_t prot_act, prot_genrtd;
    bit [2:0] inj_cntl;

    if (! $value$plusargs("inj_cntl=%d", inj_cntl)) begin
        inj_cntl = 0;
    end
    smi_check_err = FN_NOERROR;
    dat_out       = dat_in;

    <% if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
	  prot_act    = (dat_in >> pld_len) & 1'b1;
	  prot_genrtd = checkPARITY_N(dat_in, pld_len);
    <% } %>
    <% if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
          prot_act    = (dat_in >> pld_len) & ((1 << (full_len-pld_len))-1);
	  prot_genrtd = checkSECDED_N(dat_in, pld_len, full_len-pld_len);
    <% } %>

    <% if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
       if (prot_act != prot_genrtd) begin
          smi_check_err = PARITY_ERR;
          if ($test$plusargs("inject_smi_uncorr_error") || (inj_cntl[2]) || $test$plusargs("test_unit_duplication")) begin
               `uvm_info($sformatf("%m"), $sformatf("DETECTED UNCORR Parity Error"), UVM_DEBUG)
          end else begin
             `uvm_error($sformatf("%m"), $sformatf("DETECTED Unexpected UNCORR Parity Error"))
          end
       end
    <% } %>
    <% if (chipletObj[0].AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
       `uvm_info($sformatf("%m"), $sformatf("RAW Error: full length=%0d, pld length=%0d, ECC act=%p, ECC gen=%p",
                                            full_len, pld_len, prot_act, prot_genrtd), UVM_MEDIUM)
       begin
           smi_ndp_protection_t err_loc;           
           smi_ndp_bit_t        corr_mask;
           bit                  prot_msb_eq;
           int                  adjusted_err_loc;

           err_loc          = (prot_genrtd & ((1 << (full_len-pld_len-1))-1));
           adjusted_err_loc = adjust_err_loc(pld_len, err_loc);

           if (err_loc == 0) begin
             if (^(dat_in) != 0) begin
                if ((^dat_in) != ((prot_genrtd >> (full_len-1)) & 1)) begin
                   // error in protection bits
                   smi_check_err = CORR_ECC_ERR;
                  `uvm_info($sformatf("%m"), $sformatf("RAW Error: Error detected (err_loc=%0d input parity=%0d Nparity=%0d adj_err_loc=%0d)",
                                                        err_loc, ^dat_in, prot_genrtd>>(full_len-1), adjusted_err_loc), UVM_MEDIUM)
                   corr_mask = (1 << (full_len-1));
                   `uvm_info($sformatf("%m"), $sformatf("RAW Error: Corr Error detected: dat_in:%p ECC act:%p ECC gen:%p: Error loc: %0d",
                                                        dat_in & ((1<<pld_len)-1), (dat_in>>pld_len)&'hff, prot_genrtd, err_loc), UVM_MEDIUM)
                   dat_out = dat_in ^ corr_mask;
                   `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: Corr mask:%p, dat_in:%p, dat_out:%p", corr_mask, dat_in, dat_out), UVM_MEDIUM)
                end else begin
                   smi_check_err = UNCORR_ECC_ERR;
                   `uvm_warning($sformatf("%m"), $sformatf("RAW Error: No Error detected? (err_loc=%0d input parity=%0d Nparity=%0d adj_err_loc=%0d)",
                                                            err_loc, ^dat_in, prot_genrtd>>(full_len-1), adjusted_err_loc))
                end
             end else begin
                 `uvm_info($sformatf("%m"), $sformatf("RAW Error: NO Error detected"), UVM_MEDIUM)
                  smi_check_err = FN_NOERROR;
             end
           end else if ((^dat_in) == 0) begin : UNCORR
             smi_check_err = UNCORR_ECC_ERR;
             `uvm_info($sformatf("%m"), $sformatf("RAW Error: UNcorrectable Error detected in ^%0b=%0d (ndp+ecc parity == 0 err_loc=%0d adj_err_loc=%0d)",
                                                  dat_in, ^dat_in, err_loc, adjusted_err_loc), UVM_NONE)
           end else begin : CORR
              smi_check_err = CORR_ECC_ERR;
              if (adjusted_err_loc < full_len) begin
                 `uvm_info($sformatf("%m"), $sformatf("RAW Error: full length = %0d, pld length = %0d, ECC act = %p, ECC gen = %p, loc = %0d",
                                                      full_len, pld_len, prot_act, prot_genrtd, err_loc), UVM_MEDIUM)
              end else begin
//                 smi_check_err = UNCORR_ECC_ERR;
                 adjusted_err_loc = full_len-1;
                 `uvm_warning($sformatf("%m"), $sformatf("RAW Error: pld=%p, full length = %0d, pld length = %0d, ECC act = %p, ECC gen = %p, loc = %0d adj_loc = %0d",
                                                         dat_in, full_len, pld_len, prot_act, prot_genrtd, err_loc, adjusted_err_loc))
              end
              corr_mask = (1 << adjusted_err_loc);
              if (corr_mask != 'h0) begin
                   `uvm_info($sformatf("%m"), $sformatf("RAW Error: Corr Error detected: dat_in:%p ECC act:%p ECC gen:%p: Error loc: %0d (raw loc: %0d)",
                                                        dat_in & ((1<<pld_len)-1), (dat_in>>pld_len)&'hff, prot_genrtd, adjusted_err_loc, err_loc), UVM_MEDIUM)
              end
              dat_out = dat_in ^ corr_mask;                                                                 
              if (dat_in != dat_out) begin
                 `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG: Corr mask:%p, dat_in:%p, dat_out:%p", corr_mask, dat_in, dat_out), UVM_MEDIUM)
              end
          end : CORR
       end // else: !if(prot_genrtd == 0)
     <% } %>
endfunction : smi_check_err;

function int adjust_err_loc(int pld_len, int err_loc);
   if (err_loc < 3   ) return (pld_len + err_loc - 1);
   if (err_loc < 4   ) return (err_loc - 3);
   if (err_loc == 4  ) return (pld_len + 2);
   if (err_loc < 8   ) return (err_loc - 4);
   if (err_loc == 8  ) return (pld_len + 3);
   if (err_loc < 16  ) return (err_loc - 5);
   if (err_loc == 16 ) return (pld_len + 4);
   if (err_loc < 32  ) return (err_loc - 6);
   if (err_loc == 32 ) return (pld_len + 5);
   if (err_loc < 64  ) return (err_loc - 7);
   if (err_loc == 64 ) return (pld_len + 6);
   if (err_loc < 128 ) return (err_loc - 8);
   if (err_loc == 128) return (pld_len + 7);
   if (err_loc < 256 ) return (err_loc - 9);
   if (err_loc == 256) return (pld_len + 8);
   `uvm_error($sformatf("%m"), $sformatf("ECC DEBUG: Error location out of bounds: err_loc=%0d pld_size=%0d", err_loc, pld_len))
endfunction : adjust_err_loc

function bit check_err_inj_msg_type(smi_msg_type_bit_t msg_type);
   eMsgCMD       eCmdMsg;
   eMsgCCmdRsp	 eCmdRsp;
   eMsgNCCmdRsp	 eNcCmdRsp;
   eMsgSNP       eSnpMsg;
   eMsgSnpRsp    eSnpRsp;
   eMsgMRD       eMrdMsg;
   eMsgMrdRsp    eMrdRsp;
   eMsgSTR       eStrMsg;
   eMsgStrRsp    eStrRsp;
   eMsgDTR       eDtrMsg;
   eMsgDtrRsp    eDtrRsp;
   eMsgDTW       eDtwMsg;
   eMsgDTWMrgMRD eDtwMrgMsg;
   eMsgDtwRsp    eDtwRsp;
   eMsgDtwDbgReq eDtwDbgMsg;
   eMsgDtwDbgRsp eDtwDbgRsp;
   eMsgUPD       eUpdMsg;
   eMsgUpdRsp    eUpdRsp;
   eMsgRBReq     eRbMsg;
   eMsgRBRsp     eRbRsp;
   eMsgRBUsed    eRbuMsg;
   eMsgRBUseRsp	 eRbuRsp;
   eMsgCmpRsp    eCmpRsp;
   eMsgSysReq    eSysReq;
   eMsgSysRsp    eSysRsp;

   bit is_match;

   is_match = 0;

   if ($test$plusargs("cmd_req_err_inj") && (msg_type inside {[eCmdMsg.first():eCmdMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: CmdReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("ccmd_rsp_err_inj") && (msg_type inside {[eCmdRsp.first():eCmdRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: C-CmdRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("nccmd_rsp_err_inj") && (msg_type inside {[eNcCmdRsp.first():eNcCmdRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: NC-CmdRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("snp_req_err_inj") && (msg_type inside {[eSnpMsg.first():eSnpMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: SnpReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("snp_rsp_err_inj") && (msg_type inside {[eSnpRsp.first():eSnpRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: SnpRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("mrd_req_err_inj") && (msg_type inside {[eMrdMsg.first():eMrdMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: MrdReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("mrd_rsp_err_inj") && (msg_type inside {[eMrdRsp.first():eMrdRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: MrdRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("str_req_err_inj") && (msg_type inside {[eStrMsg.first():eStrMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: StrReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("str_rsp_err_inj") && (msg_type inside {[eStrRsp.first():eStrRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: StrRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("dtr_req_err_inj") && (msg_type inside {[eDtrMsg.first():eDtrMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: DtrReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("dtr_rsp_err_inj") && (msg_type inside {[eDtrRsp.first():eDtrRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: DtrRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("dtw_req_err_inj") && (msg_type inside {[eDtwMsg.first():eDtwMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: DtwReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("dtw_dbg_req_err_inj") && (msg_type inside {[eDtwDbgMsg.first():eDtwDbgMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: DtwDbgReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("dtwmrg_req_err_inj") && (msg_type inside {[eDtwMrgMsg.first():eDtwMrgMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: DtwMrgMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("dtw_rsp_err_inj") && (msg_type inside {[eDtwRsp.first():eDtwRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: DtwRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("dtw_dbg_rsp_err_inj") && (msg_type inside {[eDtwDbgRsp.first():eDtwDbgRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: DtwDbgRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("upd_req_err_inj") && (msg_type inside {[eUpdMsg.first():eUpdMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: UpdReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("upd_rsp_err_inj") && (msg_type inside {[eUpdRsp.first():eUpdRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: UpdRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("rbr_req_err_inj") && (msg_type inside {[eRbMsg.first():eRbMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: RbReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("rbr_rsp_err_inj") && (msg_type inside {[eRbRsp.first():eRbRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: RbRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("rbu_req_err_inj") && (msg_type inside {[eRbuMsg.first():eRbuMsg.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: RbuReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("rbu_rsp_err_inj") && (msg_type inside {[eRbuRsp.first():eRbuRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: RbuRspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("cmp_rsp_err_inj") && (msg_type inside {[eCmpRsp.first():eCmpRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: CmprspMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("sys_req_err_inj") && (msg_type inside {[eSysReq.first():eSysReq.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: SysReqMsg (%0h)", msg_type), UVM_DEBUG)
   end else if ($test$plusargs("sys_rsp_err_inj") && (msg_type inside {[eSysRsp.first():eSysRsp.last()]})) begin
      is_match = 1;
      `uvm_info($sformatf("%m"), $sformatf("get: SysRspMsg (%0h)", msg_type), UVM_DEBUG)
   end
   return is_match;
endfunction : check_err_inj_msg_type
<% } %>


