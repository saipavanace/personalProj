//============================================================================
//CHI Interface
//
//This interface connects request nodes (RN-F, RN-D, RN-I)
//to home nodes (HN-F, HN-I)
//This interface connects home nodes to slave nodes (SN-F, SN-I)
//
//In a system multiple instances of this interface will exist 
//with various directions
//
//Notes:
//    1. Implementation goal is that we don't have to use any Prep code
//       other than <%=obj.BlockId%>
//       hence we use Parameters to determine the interface {is it RN or a SN}
//    2. Even Assertions can be enabled or disabled using these parameters.
//       Please view below assertions for examples.
//
//Advantages over old approach
//       Though Enabling/Disabling code using 'prep' seems simpler,
//       It is prone to errors and hard to
//       debug for various configurations. Since the generated file 
//       is exactly same has actual file
//       (Line numbers match). Most of the compile errors are easy
//       to fix.
//
//       Fewer number of test cases will cover all SW configurations
//       because entire code is compiled 
//       all the time (SV code is much denser)
//============================================================================

typedef enum int {
    <%=obj.BlockId%>_RN_F,
    <%=obj.BlockId%>_RN_D,
    <%=obj.BlockId%>_RN_I,
    <%=obj.BlockId%>_SN_F,
    <%=obj.BlockId%>_SN_I
} <%=obj.BlockId%>_if_node_type_t;

<%if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.checkType != "NONE") {%>
    `ifndef IP_ENUMS
        `define IP_ENUMS
        typedef enum bit[1:0] {FLIT, FLITV, PEND} t_flit;
        typedef enum bit[1:0] {SACTIVE, RX_LINK_ACTIVE, TX_LINK_ACTIVE} t_common;
        typedef enum bit[7:0] {SYSCO, COMMON, REQ, CRSP, WDAT, RDAT, SNP, SRSP} t_channel;
    `endif
<%}%>

interface <%=obj.BlockId%>_chi_if #(parameter <%=obj.BlockId%>_if_node_type_t
  NODE_TYPE = <%=obj.BlockId%>_RN_F) (input wire clk, reset_n);

import <%=obj.BlockId%>_chi_agent_pkg::*;

//===================================
//Interface Specific Signals
//===================================
wire logic                                             tx_sactive;
wire logic                                             rx_sactive;

wire logic                                             sysco_req;
wire logic                                             sysco_ack;

//===================================
//TxLink specific signals
//===================================
wire logic                                             tx_link_active_req;
wire logic                                             tx_link_active_ack;

//===================================
//RxLink specific signals
//===================================
wire logic                                             rx_link_active_req;
wire logic                                             rx_link_active_ack;

//===================================
//TxREQ channel interface signals
//===================================
wire logic                                             tx_req_flit_pend;
wire logic                                             tx_req_flitv;
wire logic [WREQFLIT-1: 0]                             tx_req_flit;
wire logic                                             tx_req_lcrdv;

//===================================
//TxRSP channel interface signals
//===================================
wire logic                                             tx_rsp_flit_pend;
wire logic                                             tx_rsp_flitv;
wire logic [WRSPFLIT-1: 0]                             tx_rsp_flit;
wire logic                                             tx_rsp_lcrdv;

//===================================
//TxDAT channel interface signals
//===================================
wire logic                                             tx_dat_flit_pend;
wire logic                                             tx_dat_flitv;
wire logic [WDATFLIT-1: 0]                             tx_dat_flit;
wire logic                                             tx_dat_lcrdv;

//===================================
//RxRSP channel interface signals
//===================================
wire logic                                             rx_rsp_flit_pend;
wire logic                                             rx_rsp_flitv;
wire logic [WRSPFLIT-1: 0]                             rx_rsp_flit;
wire logic                                             rx_rsp_lcrdv;

//===================================
//RxDAT channel interface signals
//===================================
wire logic                                             rx_dat_flit_pend;
wire logic                                             rx_dat_flitv;
wire logic [WDATFLIT-1: 0]                             rx_dat_flit;
wire logic                                             rx_dat_lcrdv;

//===================================
//RxSNP channel interface signals
//===================================
wire logic                                             rx_snp_flit_pend;
wire logic                                             rx_snp_flitv;
wire logic [WSNPFLIT-1: 0]                             rx_snp_flit;
wire logic                                             rx_snp_lcrdv;

//===================================
//RxREQ channel interface signals
//===================================
wire logic                                             rx_req_flit_pend;
wire logic                                             rx_req_flitv;
wire logic [WREQFLIT-1: 0]                             rx_req_flit;
tri0 logic                                             rx_req_lcrdv; // init to zero (legacy...)

//===================================
// Interface Parity signals
//===================================
<%if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.checkType != "NONE") {%>
    //===================================
    //Interface Specific Signals
    //===================================
    logic                                             tx_sactive_chk;
    logic                                             rx_sactive_chk;

    logic                                             sysco_req_chk;
    logic                                             sysco_ack_chk;

    //===================================
    //TxLink specific signals
    //===================================
    logic                                             tx_link_active_req_chk;
    logic                                             tx_link_active_ack_chk;

    //===================================
    //RxLink specific signals
    //===================================
    logic                                             rx_link_active_req_chk;
    logic                                             rx_link_active_ack_chk;

    //===================================
    //TxREQ channel interface signals
    //===================================
    logic                                             tx_req_flit_pend_chk;
    logic                                             tx_req_flitv_chk;
    logic [((WREQFLIT/8)+(WREQFLIT%8 != 0))-1 : 0]    tx_req_flit_chk;
    logic                                             tx_req_lcrdv_chk;

    //===================================
    //TxRSP channel interface signals
    //===================================
    logic                                             tx_rsp_flit_pend_chk;
    logic                                             tx_rsp_flitv_chk;
    logic [((WRSPFLIT/8)+(WRSPFLIT%8 != 0))-1 : 0]    tx_rsp_flit_chk;
    logic                                             tx_rsp_lcrdv_chk;

    //===================================
    //TxDAT channel interface signals
    //===================================
    logic                                             tx_dat_flit_pend_chk;
    logic                                             tx_dat_flitv_chk;
    logic [((WDATFLIT/8)+(WDATFLIT%8 != 0))-1 : 0]    tx_dat_flit_chk;
    logic                                             tx_dat_lcrdv_chk;

    //===================================
    //RxRSP channel interface signals
    //===================================
    logic                                             rx_rsp_flit_pend_chk;
    logic                                             rx_rsp_flitv_chk;
    logic [((WRSPFLIT/8)+(WRSPFLIT%8 != 0))-1 : 0]    rx_rsp_flit_chk;
    logic [((WRSPFLIT/8)+(WRSPFLIT%8 != 0))-1 : 0]    exp_rx_rsp_flit_chk;
    logic                                             rx_rsp_lcrdv_chk;

    //===================================
    //RxDAT channel interface signals
    //===================================
    logic                                             rx_dat_flit_pend_chk;
    logic                                             rx_dat_flitv_chk;
    logic [((WDATFLIT/8)+(WDATFLIT%8 != 0))-1 : 0]    rx_dat_flit_chk;
    logic [((WDATFLIT/8)+(WDATFLIT%8 != 0))-1 : 0]    exp_rx_dat_flit_chk;
    logic                                             rx_dat_lcrdv_chk;

    //===================================
    //RxSNP channel interface signals
    //===================================
    logic                                             rx_snp_flit_pend_chk;
    logic                                             rx_snp_flitv_chk;
    logic [((WSNPFLIT/8)+(WSNPFLIT%8 != 0))-1 : 0]    rx_snp_flit_chk;
    logic [((WSNPFLIT/8)+(WSNPFLIT%8 != 0))-1 : 0]    exp_rx_snp_flit_chk;
    logic                                             rx_snp_lcrdv_chk;

    //===================================
    //RxREQ channel interface signals
    //===================================
    logic                                             rx_req_flit_pend_chk;
    logic                                             rx_req_flitv_chk;
    logic [((WREQFLIT/8)+(WREQFLIT%8 != 0))-1 : 0]    rx_req_flit_chk;
    logic [((WREQFLIT/8)+(WREQFLIT%8 != 0))-1 : 0]    exp_rx_req_flit_chk;
    logic                                             rx_req_lcrdv_chk;

    int err_info;
    int err_type;
    bit err_valid;
    bit mission_fault;
    bit err_det_en;
    bit err_int_en;
    bit IRQ_UC;
    bit IRQ_C;
    int index;
    int err_info_alias;
    int err_type_alias;
    bit err_valid_alias;
    string k_channel = "";
  <% if(obj.testBench == 'fsys') { %>
    bit en_chi_if_parity_inj;
  <% } %>

    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_ip_err_<%=obj.BlockId%> = ev_pool.get("ev_ip_err_<%=obj.BlockId%>");

    t_channel channel;
    t_flit    flit;
    t_common  common_channel;
    bit       corrupt_pkt;
    int       flip_bit;
    bit[15:0] introduce_error;
    
    initial begin
	if ($value$plusargs("k_channel=%s", k_channel)) begin
            `uvm_info("chi_if_<%=obj.BlockId%>",$psprintf("Setting k_channel=%0s through plusarg",k_channel),UVM_LOW)
            case(k_channel)
		"SYSCO": 	$cast(channel,0);
		"COMMON": 	$cast(channel,1);
		"REQ": 		$cast(channel,2);
		"CRSP": 	$cast(channel,3);
		"WDAT": 	$cast(channel,4);
		"RDAT": 	$cast(channel,5);
		"SNP": 		$cast(channel,6);
		"SRSP": 	$cast(channel,7);
            endcase
	end else begin
            std::randomize(channel) with {channel dist { SYSCO:=1, COMMON:=1, REQ:=1, CRSP:=1, WDAT:=1, RDAT:=1, SNP:=1, SRSP:=1}; };
	end
        std::randomize(flit) with {flit dist { FLIT:=1, FLITV:=1, PEND:=1}; };
        std::randomize(common_channel) with {common_channel dist { SACTIVE:=1, RX_LINK_ACTIVE:=1, TX_LINK_ACTIVE:=1}; };
        std::randomize(corrupt_pkt) with {corrupt_pkt inside { 0, 1}; };

        introduce_error = 16'd0;

        if ($test$plusargs("ip_error_test")) begin : _ip_error_test_
  <% if(obj.testBench == 'fsys') { %>
          if (en_chi_if_parity_inj==1) begin : _en_chi_if_parity_inj_
  <% } %>
            #($urandom_range(20,15) * 1us );
            case(channel)
                SYSCO: begin
                    introduce_error[15] = 1;
                    $display("INTERFACE PARITY: Err Introduced on sysco_req channel at time: %0t", $realtime);
                end
                COMMON: begin
                    case(common_channel)
                        SACTIVE: begin
                            introduce_error[14] = 1;
                            $display("INTERFACE PARITY: Err Introduced on tx sactive channel at time: %0t", $realtime);
                        end
                        RX_LINK_ACTIVE: begin
                            introduce_error[13] = 1;
                            $display("INTERFACE PARITY: Err Introduced on rx link active channel at time: %0t", $realtime);
                        end
                        TX_LINK_ACTIVE: begin
                            introduce_error[12] = 1;
                            $display("INTERFACE PARITY: Err Introduced on tx link active channel at time: %0t", $realtime);
                        end
                    endcase
                end
                REQ: begin
                    case(flit)
                        FLIT: begin
                            if (corrupt_pkt) begin
                                @(posedge tx_req_flitv);
                                introduce_error[11] = 1;
                            end
                            flip_bit = $urandom_range(($bits(tx_req_flit_chk) - 1), 0);
                            $display("INTERFACE PARITY: Err Introduced on req flit on bit:%0d at time: %0t", flip_bit, $realtime);
                        end
                        PEND: begin
                            introduce_error[10] = 1;
                            $display("INTERFACE PARITY: Err Introduced on req flit pend signal at time: %0t", $realtime);
                        end
                        FLITV: begin
                            introduce_error[9] = 1;
                            $display("INTERFACE PARITY: Err Introduced on req flit valid signal at time: %0t", $realtime);
                        end
                    endcase
                end
                CRSP: begin
                    introduce_error[8] = 1;
                    $display("INTERFACE PARITY: Err Introduced on crsp flit lcrdv signal at time: %0t", $realtime);
                end
                WDAT: begin
                    case(flit)
                        FLIT: begin
                            if (corrupt_pkt) begin
                                @(posedge tx_dat_flitv);
                                introduce_error[7] = 1;
                            end
                            flip_bit = $urandom_range(($bits(tx_dat_flit_chk) - 1), 0);
                            $display("INTERFACE PARITY: Err Introduced on wdat flit at bit:%0d at time: %0t", flip_bit, $realtime);
                        end
                        PEND: begin
                            introduce_error[6] = 1;
                            $display("INTERFACE PARITY: Err Introduced on data flit pend signal at time: %0t", $realtime);
                        end
                        FLITV: begin
                            introduce_error[5] = 1;
                            $display("INTERFACE PARITY: Err Introduced on data flit valid signal at time: %0t", $realtime);
                        end
                    endcase
                end
                RDAT: begin
                    introduce_error[4] = 1;
                    $display("INTERFACE PARITY: Err Introduced on rdata lcrdv signal at time: %0t", $realtime);
                end
                SNP: begin
                    introduce_error[3] = 1;
                    $display("INTERFACE PARITY: Err Introduced on snp lcrdv signal at time: %0t", $realtime);
                end
                SRSP: begin
                    case(flit)
                        FLIT: begin
                            flip_bit = $urandom_range(($bits(tx_rsp_flit_chk) - 1), 0);
                            if (corrupt_pkt) begin
                                @(posedge tx_rsp_flitv);
                                introduce_error[2] = 1;
                            end
                            $display("INTERFACE PARITY: Err Introduced on srsp flit on bit:%0d at time: %0t", flip_bit, $realtime);
                        end
                        PEND: begin
                            introduce_error[1] = 1;
                            $display("INTERFACE PARITY: Err Introduced on snp pend signal at time: %0t", $realtime);
                        end
                        FLITV: begin
                            introduce_error[0] = 1;
                            $display("INTERFACE PARITY: Err Introduced on snp flit valid signal at time: %0t", $realtime);
                        end
                    endcase
                end
            endcase
            repeat(5) begin // Wait for interrupts to propagate
                @ (posedge clk);
            end
            `uvm_info("chi_if_<%=obj.BlockId%>",$psprintf("channel=%0s flit=%0s common_channel=%0s introduce_error='h%0h",channel.name(),flit.name(),common_channel.name(),introduce_error),UVM_LOW)
            check_errorinfo(introduce_error);
            introduce_error = 0;
  <% if(obj.testBench == 'fsys') { %>
          end : _en_chi_if_parity_inj_
  <% } %>
        end : _ip_error_test_
    end

    <% if(obj.testBench !== 'emu_t') { %>
    always@(posedge clk) begin
        if ($test$plusargs("ip_error_test")) begin
            if (rx_sactive_chk == rx_sactive) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: rx_sactive_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_sactive, rx_sactive_chk)); 
	    end

            if (sysco_ack_chk == sysco_ack) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: sysco_ack_chk Expected: 0x%0h Actual: 0x%0h", index, !sysco_ack, sysco_ack_chk)); 
	    end

            if (rx_link_active_req_chk == rx_link_active_req) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: rx_link_active_req_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_link_active_req, rx_link_active_req_chk)); 
	    end

            if (tx_link_active_ack_chk == tx_link_active_ack) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: tx_link_active_ack_chk Expected: 0x%0h Actual: 0x%0h", index, !tx_link_active_ack, tx_link_active_ack_chk)); 
	    end

            if (rx_rsp_flit_pend_chk == rx_rsp_flit_pend) begin
       	       	`uvm_error("IP Err", $sformatf("CHI%0d: rx_rsp_flit_pend_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_rsp_flit_pend, rx_rsp_flit_pend_chk)); 
	    end

            if (rx_rsp_flitv_chk == rx_rsp_flitv) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: rx_rsp_flitv_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_rsp_flitv, rx_rsp_flitv_chk)); 
	    end

            if (rx_dat_flit_pend_chk == rx_dat_flit_pend) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: rx_dat_flit_pend_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_dat_flit_pend, rx_dat_flit_pend_chk)); 
	    end

            if (rx_dat_flitv_chk == rx_dat_flitv) begin
       	       	`uvm_error("IP Err", $sformatf("CHI%0d: rx_dat_flitv_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_dat_flitv, rx_dat_flitv_chk)); 
	    end

            if (tx_req_lcrdv_chk == tx_req_lcrdv) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: tx_req_lcrdv_chk Expected: 0x%0h Actual: 0x%0h", index, !tx_req_lcrdv, tx_req_lcrdv_chk)); 
	    end

            if (tx_rsp_lcrdv_chk == tx_rsp_lcrdv) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: tx_rsp_lcrdv_chk Expected: 0x%0h Actual: 0x%0h", index, !tx_rsp_lcrdv, tx_rsp_lcrdv_chk)); 
	    end

            if (tx_dat_lcrdv_chk == tx_dat_lcrdv) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: tx_dat_lcrdv_chk Expected: 0x%0h Actual: 0x%0h", index, !tx_dat_lcrdv, tx_dat_lcrdv_chk)); 
	    end

            if (rx_snp_flit_pend_chk == rx_snp_flit_pend) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: rx_snp_flit_pend_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_snp_flit_pend, rx_snp_flit_pend_chk)); 
	    end

            if (rx_snp_flitv_chk == rx_snp_flitv) begin
       	        `uvm_error("IP Err", $sformatf("CHI%0d: rx_snp_flitv_chk Expected: 0x%0h Actual: 0x%0h", index, !rx_snp_flitv, rx_snp_flitv_chk)); 
	    end

            foreach(rx_rsp_flit_chk[i]) begin
	    	exp_rx_rsp_flit_chk[i] = (($countones(rx_rsp_flit[(i*8) +: 8])) % 2 == 0);
            	if (exp_rx_rsp_flit_chk[i] != rx_rsp_flit_chk[i]) begin
       	    	    `uvm_error("IP Err", $sformatf("CHI%0d: rx_rsp_flit_chk[%0d] Expected: %0b Actual: %0b", index, i, exp_rx_rsp_flit_chk[i], rx_rsp_flit_chk[i])); 
	    	end
            end

            foreach(rx_dat_flit_chk[i]) begin
	    	exp_rx_dat_flit_chk[i] = (($countones(rx_dat_flit[(i*8) +: 8])) % 2 == 0);
            	if (exp_rx_dat_flit_chk[i] != rx_dat_flit_chk[i]) begin
       	    	    `uvm_error("IP Err", $sformatf("CHI%0d: rx_dat_flit_chk[%0d] Expected: %0b Actual: %0b", index, i, exp_rx_dat_flit_chk[i], rx_dat_flit_chk[i])); 
	    	end
            end

            foreach(rx_snp_flit_chk[i]) begin
	    	exp_rx_snp_flit_chk[i] = (($countones(rx_snp_flit[(i*8) +: 8])) % 2 == 0);
            	if (exp_rx_snp_flit_chk[i] != rx_snp_flit_chk[i]) begin
       	    	    `uvm_error("IP Err", $sformatf("CHI%0d: rx_snp_flit_chk[%0d] Expected: %0b Actual: %0b", index, i, exp_rx_snp_flit_chk[i], rx_snp_flit_chk[i])); 
	    	end
            end
        end
    end
    <%}%>

    function void check_errorinfo(bit[15:0] code);
        // #Check.CHI.v3.6.InterfaceParity.Error.Command_drop
        // #Check.CHI.v3.6.InterfaceParity.Error
        // #Check.CHI.v3.7.InterfaceParity.NoError
        // #Check.CHI.v3.7.InterfaceParity.Error
        <% if(obj.testBench !== 'emu_t') { %>
            if (code == 'h0) begin
                if (err_type != 'h0 || err_valid || IRQ_UC) begin
                    `uvm_error("IP Err", $sformatf("CHI%0d: There is no error injected in this scenario. Expected: All zeros actual- err_type:0x%0h, err_valid:%0b, IRQ_UC:%0b ", index, err_type, err_valid, IRQ_UC)); 
                end
            end else begin
                if (err_type != 'hD && err_det_en) begin
                    `uvm_error("IP Err", $sformatf("CHI%0d: Wrong error info type when ip error is inserted. Expected:0xd, actual:0x%0h (%0d type err introduced)", index, err_type, code)); 
                end
                if (!err_valid && err_det_en) begin
                    `uvm_error("IP Err", $sformatf("CHI%0d: Error Valid not asserted when ip error is inserted", index)); 
                end
                if (err_valid && !err_det_en) begin
                    `uvm_error("IP Err", $sformatf("CHI%0d: Error Valid is asserted when error detect is disabled", index)); 
                end
                if (!IRQ_UC && (err_int_en && err_det_en)) begin
                    `uvm_error("IP Err", $sformatf("CHI%0d: IRQ_UC interrupt not asserted when ip error is inserted", index)); 
                end
                if (IRQ_UC && !err_int_en) begin
                    `uvm_error("IP Err", $sformatf("CHI%0d: IRQ_UC interrupt asserted when interrupt is disabled", index)); 
                end
                if (!mission_fault) begin
                    `uvm_error("IP Err", $sformatf("CHI%0d: mission_fault is not asserted when ip error is inserted", index)); 
                end
            end
            
            if (err_det_en) begin
                case(1)
                    code[0],code[1],code[2] : begin
                        if (err_info != 'hD) begin
                            `uvm_error("IP Err", $sformatf("CHI%0d: Wrong err_info for SRSP channel. Expected: 0xd, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    code[3] : begin
                        if (err_info != 'hC) begin
                            `uvm_error("IP Err", $sformatf("CHI%0d: Wrong err_info for SNP channel. Expected: 0xc, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    code[4] : begin
                        if (err_info != 'hB) begin
                            `uvm_error("IP Errr", $sformatf("CHI%0d: Wrong err_info for RDATA channel. Expected: 0xb, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    code[5],code[6],code[7] : begin
                        if (err_info != 'hA) begin
                            `uvm_error("IP Errr", $sformatf("CHI%0d: Wrong err_type for WDATA channel. Expected: 0xa, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    code[8] : begin
                        if (err_info != 'h9) begin
                            `uvm_error("IP Err",$sformatf("CHI%0d: Wrong err_type for CRSP channel. Expected: 0x9, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    code[9],code[10],code[11] : begin
                        if (err_info != 'h8) begin
                            `uvm_error("IP Err",$sformatf("CHI%0d: Wrong err_type for REQ channel. Expected: 0x8, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    code[12],code[13],code[14] : begin
                        if (err_info != 'hF) begin
                            `uvm_error("IP Err",$sformatf("CHI%0d: Wrong err_type for COMMON channel. Expected: 0xf, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    code[15] : begin
                        if (err_info != 'hE) begin
                            `uvm_error("IP Err",$sformatf("CHI%0d: Wrong err_type for SYSCO channel. Expected: 0xe, Actual:0x%0h", index, err_info)); 
                        end
                    end
                    default : begin
                        if (err_info != 'h0) begin
                            `uvm_error("IP Err",$sformatf("CHI%0d: Wrong error type when no error is introduced. Expected: 0x0, Actual:0x%0h", index, err_info)); 
                        end
                    end
                endcase
            end
        <%}%>
    endfunction: check_errorinfo


    always_comb begin
        tx_sactive_chk = introduce_error[14] ? tx_sactive : !tx_sactive;
        sysco_req_chk = introduce_error[15] ? sysco_req : !sysco_req;
        rx_link_active_ack_chk = introduce_error[13] ? rx_link_active_ack : !rx_link_active_ack;
        tx_link_active_req_chk = introduce_error[12] ? tx_link_active_req : !tx_link_active_req;

        tx_req_flit_pend_chk = introduce_error[10] ? tx_req_flit_pend : !tx_req_flit_pend;
        tx_req_flitv_chk = introduce_error[9] ? tx_req_flitv : !tx_req_flitv;
        
        tx_rsp_flit_pend_chk = introduce_error[1] ? tx_rsp_flit_pend : !tx_rsp_flit_pend;
        tx_rsp_flitv_chk = introduce_error[0] ? tx_rsp_flitv : !tx_rsp_flitv;

        tx_dat_flit_pend_chk = introduce_error[6] ? tx_dat_flit_pend : !tx_dat_flit_pend;
        tx_dat_flitv_chk = introduce_error[5] ? tx_dat_flitv : !tx_dat_flitv;

        rx_rsp_lcrdv_chk = introduce_error[8] ? rx_rsp_lcrdv : !rx_rsp_lcrdv;
        rx_dat_lcrdv_chk = introduce_error[4] ? rx_dat_lcrdv : !rx_dat_lcrdv;
        rx_snp_lcrdv_chk = introduce_error[3] ? rx_snp_lcrdv : !rx_snp_lcrdv;
        rx_req_lcrdv_chk = !rx_req_lcrdv;

        foreach(tx_req_flit_chk[i]) begin
            if ((i == flip_bit) && introduce_error[11]) begin
                tx_req_flit_chk[i] = !(($countones(tx_req_flit[(i*8) +: 8])) % 2 == 0);
            end else begin
                tx_req_flit_chk[i] = (($countones(tx_req_flit[(i*8) +: 8])) % 2 == 0);
            end
        end

        foreach(tx_req_flit_chk[i]) begin
            tx_req_flit_chk[i] = (($countones(tx_req_flit[(i*8) +: 8])) % 2 == 0);
        end

        foreach(tx_rsp_flit_chk[i]) begin
            if ((i == flip_bit) && introduce_error[2]) begin
                tx_rsp_flit_chk[i] = !(($countones(tx_rsp_flit[(i*8) +: 8])) % 2 == 0);
            end else begin
                tx_rsp_flit_chk[i] = (($countones(tx_rsp_flit[(i*8) +: 8])) % 2 == 0);
            end
        end

        foreach(tx_dat_flit_chk[i]) begin
            if ((i == flip_bit) && introduce_error[7]) begin
                tx_dat_flit_chk[i] = !(($countones(tx_dat_flit[(i*8) +: 8])) % 2 == 0);
            end else begin
                tx_dat_flit_chk[i] = (($countones(tx_dat_flit[(i*8) +: 8])) % 2 == 0);
            end
        end
    end

    
    always @(posedge clk) begin
    	uvm_config_db#(bit)::set(null,"*", "<%=obj.BlockId%>_ip_err_err_det_en", err_det_en);
    	uvm_config_db#(bit)::set(null,"*", "<%=obj.BlockId%>_ip_err_err_int_en", err_int_en);
    	uvm_config_db#(int)::set(null,"*", "<%=obj.BlockId%>_ip_err_err_info",err_info);
    	uvm_config_db#(int)::set(null,"*", "<%=obj.BlockId%>_ip_err_err_type", err_type);
    	uvm_config_db#(bit)::set(null,"*", "<%=obj.BlockId%>_ip_err_err_valid", err_valid);
    	uvm_config_db#(bit)::set(null,"*", "<%=obj.BlockId%>_ip_err_mission_fault", mission_fault);
    	uvm_config_db#(bit)::set(null,"*", "<%=obj.BlockId%>_ip_err_IRQ_UC",IRQ_UC);
    	ev_ip_err_<%=obj.BlockId%>.trigger(null);
    end
<%}%>

    
//===================================
//RN-F, RN-D Nodes Driver Clocking Block
//===================================
clocking rn_drv_cb @(posedge clk);
    default input #1step output #1;
  <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifndef VCS
    output sysco_req, tx_sactive, tx_link_active_req, rx_link_active_ack;
    `else
    output sysco_req, tx_sactive, tx_link_active_req; 
    inout rx_link_active_ack;
    `endif // `ifndef VCS ... `else ... 
  <% } else { %>
    output sysco_req, tx_sactive, tx_link_active_req ,rx_link_active_ack; 
  <% } %>
    input  sysco_ack, rx_sactive, tx_link_active_ack, rx_link_active_req;
    //Tx
    output tx_req_flit_pend, tx_req_flitv, tx_req_flit;
    input  tx_req_lcrdv;
    output tx_rsp_flit_pend, tx_rsp_flitv, tx_rsp_flit;
    input  tx_rsp_lcrdv;
    output tx_dat_flit_pend, tx_dat_flitv, tx_dat_flit;
    input  tx_dat_lcrdv;
    //Rx
    input  rx_rsp_flit_pend, rx_rsp_flitv, rx_rsp_flit;
    output rx_rsp_lcrdv;
    input  rx_dat_flit_pend, rx_dat_flitv, rx_dat_flit;
    output rx_dat_lcrdv;
    input  rx_snp_flit_pend, rx_snp_flitv, rx_snp_flit;
    output rx_snp_lcrdv;
endclocking: rn_drv_cb

//===================================
//RN-F, RN-D Nodes Monitor Clocking Block
//===================================
clocking rn_mon_cb @(negedge clk);
    default input #1step output #1;
    input  sysco_req, tx_sactive, tx_link_active_req, rx_link_active_ack;
    input  sysco_ack, rx_sactive, tx_link_active_ack, rx_link_active_req;
    //Tx
    input tx_req_flit_pend, tx_req_flitv, tx_req_flit, tx_req_lcrdv;
    input tx_rsp_flit_pend, tx_rsp_flitv, tx_rsp_flit, tx_rsp_lcrdv;
    input tx_dat_flit_pend, tx_dat_flitv, tx_dat_flit, tx_dat_lcrdv;
    //Rx
    input  rx_rsp_flit_pend, rx_rsp_flitv, rx_rsp_flit, rx_rsp_lcrdv;
    input  rx_dat_flit_pend, rx_dat_flitv, rx_dat_flit, rx_dat_lcrdv;
    input  rx_snp_flit_pend, rx_snp_flitv, rx_snp_flit, rx_snp_lcrdv;
endclocking: rn_mon_cb

//===================================
//RN-I, Nodes Driver Clocking Block
//===================================
clocking rni_drv_cb @(posedge clk);
    default input #1step output #1;
  <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifndef VCS
    output sysco_req, tx_sactive, tx_link_active_req, rx_link_active_ack;
    `else
    output sysco_req, tx_sactive, tx_link_active_req;
    inout rx_link_active_ack;
    `endif // `ifndef VCS ... `else ... 
  <% } else { %>
    output sysco_req, tx_sactive, tx_link_active_req, rx_link_active_ack;
  <% } %>
    input  sysco_ack, rx_sactive, tx_link_active_ack, rx_link_active_req;
    //Tx
    output tx_req_flit_pend, tx_req_flitv, tx_req_flit;
    input  tx_req_lcrdv;
    output tx_rsp_flit_pend, tx_rsp_flitv, tx_rsp_flit;
    input  tx_rsp_lcrdv;
    output tx_dat_flit_pend, tx_dat_flitv, tx_dat_flit;
    input  tx_dat_lcrdv;
    //Rx
    input  rx_rsp_flit_pend, rx_rsp_flitv, rx_rsp_flit;
    output rx_rsp_lcrdv;
    input  rx_dat_flit_pend, rx_dat_flitv, rx_dat_flit;
    output rx_dat_lcrdv;
endclocking: rni_drv_cb

//===================================
//RN-F, RN-D Nodes Monitor Clocking Block
//===================================
clocking rni_mon_cb @(negedge clk);
    default input #1step output #1;
    input  sysco_req, tx_sactive, tx_link_active_req, rx_link_active_ack;
    input  sysco_ack, rx_sactive, tx_link_active_ack, rx_link_active_req;
    //Tx
    input tx_req_flit_pend, tx_req_flitv, tx_req_flit, tx_req_lcrdv;
    input tx_rsp_flit_pend, tx_rsp_flitv, tx_rsp_flit, tx_rsp_lcrdv;
    input tx_dat_flit_pend, tx_dat_flitv, tx_dat_flit, tx_dat_lcrdv;
    //Rx
    input  rx_rsp_flit_pend, rx_rsp_flitv, rx_rsp_flit, rx_rsp_lcrdv;
    input  rx_dat_flit_pend, rx_dat_flitv, rx_dat_flit, rx_dat_lcrdv;
endclocking: rni_mon_cb

//===================================
//SN-F, SF-I Nodes Driver Clocking Block
//===================================
clocking sn_drv_cb @(posedge clk);
    default input #1step output #1;
  <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifndef VCS
    output sysco_ack, tx_sactive, tx_link_active_req, rx_link_active_ack;
    `else
    output sysco_ack, tx_sactive, tx_link_active_req;
    inout rx_link_active_ack;
    `endif // `ifndef VCS ... `else ... 
  <% } else { %>
    output sysco_ack, tx_sactive, tx_link_active_req, rx_link_active_ack;
  <% } %>
    input  sysco_req, rx_sactive, tx_link_active_ack, rx_link_active_req;
    //Tx
    output tx_rsp_flit_pend, tx_rsp_flitv, tx_rsp_flit;
    input  tx_rsp_lcrdv;
    output tx_dat_flit_pend, tx_dat_flitv, tx_dat_flit;
    input  tx_dat_lcrdv;
    //Rx
    input  rx_req_flit_pend, rx_req_flitv, rx_req_flit;
    output rx_req_lcrdv;
    input  rx_dat_flit_pend, rx_dat_flitv, rx_dat_flit;
    output rx_dat_lcrdv;
  <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
    `ifdef VCS
    input  rx_rsp_flitv, rx_rsp_flit;
    output rx_rsp_lcrdv;
    `endif // `ifndef VCS ... `else ... 
  <% } %>
endclocking: sn_drv_cb

//===================================
//SN-F, SF-I Nodes Monitor Clocking Block
//===================================
clocking sn_mon_cb @(negedge clk);
    default input #1step output #1;
    input sysco_ack, tx_sactive, tx_link_active_req, rx_link_active_ack;
    input sysco_req, rx_sactive, tx_link_active_ack, rx_link_active_req;
    //Tx
    input tx_rsp_flit_pend, tx_rsp_flitv, tx_rsp_flit;
    input tx_rsp_lcrdv;
    input tx_dat_flit_pend, tx_dat_flitv, tx_dat_flit;
    input tx_dat_lcrdv;
    //Rx
    input rx_req_flit_pend, rx_req_flitv, rx_req_flit;
    input rx_req_lcrdv;
    input rx_dat_flit_pend, rx_dat_flitv, rx_dat_flit;
    input rx_dat_lcrdv;
  <% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
   `ifdef VCS
    input rx_rsp_flitv, rx_rsp_flit, rx_rsp_lcrdv;
   `endif // `ifndef VCS ... `else ... 
  <% } %>
endclocking: sn_mon_cb

modport rn_drv_mp(clocking  rn_drv_cb, input reset_n);
modport rn_mon_mp(clocking  rn_mon_cb, input reset_n);
modport rni_drv_mp(clocking rni_drv_cb, input reset_n);
modport rni_mon_mp(clocking rni_mon_cb, input reset_n);
modport sn_drv_mp(clocking  sn_drv_cb,  input reset_n);
modport sn_mon_mp(clocking  sn_mon_cb,  input reset_n);

endinterface: <%=obj.BlockId%>_chi_if

