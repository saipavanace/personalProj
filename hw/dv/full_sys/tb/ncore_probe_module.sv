///////////////////////////////////////////////////////////////////////
// Arteris Inc.
// 1/22/2020
// Tempo probe module
// Rev 1.4. 
// Rev 1.5
// Rev 1.6
// RSVDC field fixed from 1.4 for CHI-A, RDDAT and WDDAT. This may also be an issue for CHI-B?
// Rev 1.7
// Rev 1.8 Added ACE support for IOAIU.
// Rev 1.9 Updated for SMI support for IOAIU.
// Rev 2.0 Updated for more SMI support for IOAIU.
// Kjeld Svendsen
///////////////////////////////////////////////////////////////////////
<% if(obj.testBench == "emu") { %>
`include "uvm_macros.svh"
<% } %>

module ncore_probe_module();
//pragma attribute ncore_probe_module partition_module_xrtl

logic clk_en, clk_en1, clk_en2, clk_en3, clk_en4;

<% if(obj.testBench == "emu") { %>
integer file_handle; 
initial begin
    file_handle = $fopen("concerto_trace.txt");
	clk_en = 1'b0;
    clk_en1 = 1'b0;
    clk_en2 = 1'b0;
    clk_en3 = 1'b0;
    clk_en4 = 1'b0;
end

<% obj.AiuInfo.forEach(function(bundle, indx) { %>
<% if (indx == 0){ %>
always @(posedge ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk) begin
    clk_en1 <= 1'b1;
    clk_en2 <= clk_en1;
    clk_en3 <= clk_en2;
    clk_en4 <= clk_en3;
	clk_en  <= clk_en4;
end 
<% } %>
<% }); %>
<% } else { %>
integer file_handle = $fopen("concerto_trace.txt");
<% } %>

// Unit ID calculation
<%var smi_index = 0; %>
<%var smi_index_rx = 0; %>
<% 
var unitID = 0; 
var cidx = 0;
var ncidx = 0;
%>
// {==================================================
// AIU UNIT START
// ==================================================
<% obj.AiuInfo.forEach(function(bundle, indx) { %>

/////////////////////////////////
// CHI_B_AIU unit
/////////////////////////////////
<% if ((bundle.fnNativeInterface === "CHI-A")||(bundle.fnNativeInterface === "CHI-B")||(bundle.fnNativeInterface === "CHI-E")) { %>
    <% unitID = bundle.FUnitId; %>
    <% if(obj.testBench == "emu") { %>
    //`define CHIAIU<%=indx%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>
    `define CHIAIU<%=cidx%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>
    <% } else { %>
    //`define CHIAIU<%=indx%> tb_top.dut.<%=bundle.strRtlNamePrefix%>
<% if (bundle.hierPath && bundle.hierPath!=='') {%>
<%}else{%>
<% } %>
<% if (bundle.hierPath && bundle.hierPath!=='') {%>
    `define CHIAIU<%=cidx%> tb_top.dut.<%=bundle.instancePath%>
<%}else{%>
    `define CHIAIU<%=cidx%> tb_top.dut.<%=bundle.strRtlNamePrefix%>
<% } %>
    <% } %>

    wire [<%=bundle.interfaces.chiInt.params.REQ_RSVDC%>-1:0]   RXREQFLIT<%=cidx%>_RSVDC;
    wire [<%=bundle.interfaces.chiInt.params.TraceTag%>-1:0]    RXREQFLIT<%=cidx%>_TraceTag;
    wire                                                        RXREQFLIT<%=cidx%>_ExCompAck;
    wire                                                        RXREQFLIT<%=cidx%>_Excl;
    <% if (bundle.fnNativeInterface === "CHI-E") { %>
    wire [8-1:0]                                                RXREQFLIT<%=cidx%>_LPID;
    <%}else{%>
    wire [<%=bundle.interfaces.chiInt.params.LPID%>-1:0]        RXREQFLIT<%=cidx%>_LPID;
    <% } %>
    wire [<%=bundle.interfaces.chiInt.params.SnpAttr%>-1:0]     RXREQFLIT<%=cidx%>_SnpAttr;
    wire [<%=bundle.interfaces.chiInt.params.MemAttr%>-1:0]     RXREQFLIT<%=cidx%>_MemAttr;
    wire [<%=bundle.interfaces.chiInt.params.PCrdType%>-1:0]    RXREQFLIT<%=cidx%>_PCrdType;
    wire [<%=bundle.interfaces.chiInt.params.Order%>-1:0]       RXREQFLIT<%=cidx%>_Order;
    wire                                                        RXREQFLIT<%=cidx%>_AllowRetry;
    wire                                                        RXREQFLIT<%=cidx%>_LikelyShared;
    wire                                                        RXREQFLIT<%=cidx%>_NS;
    wire [<%=bundle.interfaces.chiInt.params.wAddr%>-1:0]       RXREQFLIT<%=cidx%>_Addr;
    wire [<%=bundle.interfaces.chiInt.params.Size%>-1:0]        RXREQFLIT<%=cidx%>_Size;
    wire [<%=bundle.interfaces.chiInt.params.REQ_Opcode%>-1:0]  RXREQFLIT<%=cidx%>_Opcode;
    wire [<%=bundle.interfaces.chiInt.params.ReturnTxnID%>-1:0] RXREQFLIT<%=cidx%>_ReturnTxnID;
    wire [<%=bundle.interfaces.chiInt.params.StashNIDValid%>-1:0] RXREQFLIT<%=cidx%>_StashNIDValid;
    wire [<%=bundle.interfaces.chiInt.params.ReturnNID%>-1:0]   RXREQFLIT<%=cidx%>_ReturnNID;
    wire [<%=bundle.interfaces.chiInt.params.TxnID%>-1:0]       RXREQFLIT<%=cidx%>_TxnID;
    wire [<%=bundle.interfaces.chiInt.params.SrcID%>-1:0]       RXREQFLIT<%=cidx%>_SrcID;
    wire [<%=bundle.interfaces.chiInt.params.TgtID%>-1:0]       RXREQFLIT<%=cidx%>_TgtID;
    wire [<%=bundle.interfaces.chiInt.params.wQos%>-1:0]        RXREQFLIT<%=cidx%>_QoS;

    wire [<%=bundle.interfaces.chiInt.params.TraceTag%>-1:0]    RXRSPFLIT<%=cidx%>_TraceTag;
    wire [<%=bundle.interfaces.chiInt.params.PCrdType%>-1:0]    RXRSPFLIT<%=cidx%>_PCrdType;
    wire [<%=bundle.interfaces.chiInt.params.DBID%>-1:0]        RXRSPFLIT<%=cidx%>_DBID;
    wire [<%=bundle.interfaces.chiInt.params.FwdState%>-1:0]    RXRSPFLIT<%=cidx%>_FwdState;
    wire [<%=bundle.interfaces.chiInt.params.Resp%>-1:0]        RXRSPFLIT<%=cidx%>_Resp;
    wire [<%=bundle.interfaces.chiInt.params.RespErr%>-1:0]     RXRSPFLIT<%=cidx%>_RespErr;
    wire [<%=bundle.interfaces.chiInt.params.RSP_Opcode%>-1:0]  RXRSPFLIT<%=cidx%>_Opcode;
    wire [<%=bundle.interfaces.chiInt.params.TxnID%>-1:0]       RXRSPFLIT<%=cidx%>_TxnID;
    wire [<%=bundle.interfaces.chiInt.params.SrcID%>-1:0]       RXRSPFLIT<%=cidx%>_SrcID;
    wire [<%=bundle.interfaces.chiInt.params.TgtID%>-1:0]       RXRSPFLIT<%=cidx%>_TgtID;
    wire [<%=bundle.interfaces.chiInt.params.wQos%>-1:0]        RXRSPFLIT<%=cidx%>_QoS;

    wire [<%=bundle.interfaces.chiInt.params.DAT_RSVDC%>-1:0]   RXDATFLIT<%=cidx%>_RSVDC;
    wire [<%=bundle.interfaces.chiInt.params.TraceTag%>-1:0]    RXDATFLIT<%=cidx%>_TraceTag;
    wire [<%=bundle.interfaces.chiInt.params.wData%>-1:0]       RXDATFLIT<%=cidx%>_Data;
    wire [<%=bundle.interfaces.chiInt.params.BE%>-1:0]          RXDATFLIT<%=cidx%>_BE;
    wire [<%=bundle.interfaces.chiInt.params.DBID%>-1:0]        RXDATFLIT<%=cidx%>_DBID;
    wire [<%=bundle.interfaces.chiInt.params.CCID%>-1:0]        RXDATFLIT<%=cidx%>_CCID;
    wire [<%=bundle.interfaces.chiInt.params.DataID%>-1:0]      RXDATFLIT<%=cidx%>_DataID;
    wire [<%=bundle.interfaces.chiInt.params.Homenode_ID%>-1:0] RXDATFLIT<%=cidx%>_HomenodeID;
    wire [<%=bundle.interfaces.chiInt.params.FwdState%>-1:0]    RXDATFLIT<%=cidx%>_FwdState;
    wire [<%=bundle.interfaces.chiInt.params.Resp%>-1:0]        RXDATFLIT<%=cidx%>_Resp;
    wire [<%=bundle.interfaces.chiInt.params.RespErr%>-1:0]     RXDATFLIT<%=cidx%>_RespErr;
    wire [<%=bundle.interfaces.chiInt.params.DAT_Opcode%>-1:0]  RXDATFLIT<%=cidx%>_Opcode;
    wire [<%=bundle.interfaces.chiInt.params.TxnID%>-1:0]       RXDATFLIT<%=cidx%>_TxnID;
    wire [<%=bundle.interfaces.chiInt.params.SrcID%>-1:0]       RXDATFLIT<%=cidx%>_SrcID;
    wire [<%=bundle.interfaces.chiInt.params.TgtID%>-1:0]       RXDATFLIT<%=cidx%>_TgtID;
    wire [<%=bundle.interfaces.chiInt.params.wQos%>-1:0]        RXDATFLIT<%=cidx%>_QoS;

    wire [<%=bundle.interfaces.chiInt.params.TraceTag%>-1:0]    TXRSPFLIT<%=cidx%>_TraceTag;
    wire [<%=bundle.interfaces.chiInt.params.PCrdType%>-1:0]    TXRSPFLIT<%=cidx%>_PCrdType;
    wire [<%=bundle.interfaces.chiInt.params.DBID%>-1:0]        TXRSPFLIT<%=cidx%>_DBID;
    wire [<%=bundle.interfaces.chiInt.params.FwdState%>-1:0]    TXRSPFLIT<%=cidx%>_FwdState;
    wire [<%=bundle.interfaces.chiInt.params.Resp%>-1:0]        TXRSPFLIT<%=cidx%>_Resp;
    wire [<%=bundle.interfaces.chiInt.params.RespErr%>-1:0]     TXRSPFLIT<%=cidx%>_RespErr;
    wire [<%=bundle.interfaces.chiInt.params.RSP_Opcode%>-1:0]  TXRSPFLIT<%=cidx%>_Opcode;
    wire [<%=bundle.interfaces.chiInt.params.TxnID%>-1:0]       TXRSPFLIT<%=cidx%>_TxnID;
    wire [<%=bundle.interfaces.chiInt.params.SrcID%>-1:0]       TXRSPFLIT<%=cidx%>_SrcID;
    wire [<%=bundle.interfaces.chiInt.params.TgtID%>-1:0]       TXRSPFLIT<%=cidx%>_TgtID;
    wire [<%=bundle.interfaces.chiInt.params.wQos%>-1:0]        TXRSPFLIT<%=cidx%>_QoS;

    wire [<%=bundle.interfaces.chiInt.params.DAT_RSVDC%>-1:0]   TXDATFLIT<%=cidx%>_RSVDC;
    wire [<%=bundle.interfaces.chiInt.params.TraceTag%>-1:0]    TXDATFLIT<%=cidx%>_TraceTag;
    wire [<%=bundle.interfaces.chiInt.params.wData%>-1:0]       TXDATFLIT<%=cidx%>_Data;
    wire [<%=bundle.interfaces.chiInt.params.BE%>-1:0]          TXDATFLIT<%=cidx%>_BE;
    wire [<%=bundle.interfaces.chiInt.params.DBID%>-1:0]        TXDATFLIT<%=cidx%>_DBID;
    wire [<%=bundle.interfaces.chiInt.params.CCID%>-1:0]        TXDATFLIT<%=cidx%>_CCID;
    wire [<%=bundle.interfaces.chiInt.params.DataID%>-1:0]      TXDATFLIT<%=cidx%>_DataID;
    wire [<%=bundle.interfaces.chiInt.params.Homenode_ID%>-1:0] TXDATFLIT<%=cidx%>_HomenodeID;
    wire [<%=bundle.interfaces.chiInt.params.FwdState%>-1:0]    TXDATFLIT<%=cidx%>_FwdState;
    wire [<%=bundle.interfaces.chiInt.params.Resp%>-1:0]        TXDATFLIT<%=cidx%>_Resp;
    wire [<%=bundle.interfaces.chiInt.params.RespErr%>-1:0]     TXDATFLIT<%=cidx%>_RespErr;
    wire [<%=bundle.interfaces.chiInt.params.DAT_Opcode%>-1:0]  TXDATFLIT<%=cidx%>_Opcode;
    wire [<%=bundle.interfaces.chiInt.params.TxnID%>-1:0]       TXDATFLIT<%=cidx%>_TxnID;
    wire [<%=bundle.interfaces.chiInt.params.SrcID%>-1:0]       TXDATFLIT<%=cidx%>_SrcID;
    wire [<%=bundle.interfaces.chiInt.params.TgtID%>-1:0]       TXDATFLIT<%=cidx%>_TgtID;
    wire [<%=bundle.interfaces.chiInt.params.wQos%>-1:0]        TXDATFLIT<%=cidx%>_QoS;

    wire [<%=bundle.interfaces.chiInt.params.TraceTag%>-1:0]    TXSNPFLIT<%=cidx%>_TraceTag;
    wire                                                        TXSNPFLIT<%=cidx%>_RetToSrc;
    wire                                                        TXSNPFLIT<%=cidx%>_DoNotGoToSD;  
    wire                                                        TXSNPFLIT<%=cidx%>_NS;
    wire [<%=bundle.interfaces.chiInt.params.wAddr%>-4:0]       TXSNPFLIT<%=cidx%>_Addr; // Notice the snoop address cuts off the 3 LSBs.
    wire [<%=bundle.interfaces.chiInt.params.SNP_Opcode%>-1:0]  TXSNPFLIT<%=cidx%>_Opcode;
    wire [<%=bundle.interfaces.chiInt.params.FwdTxnID%>-1:0]    TXSNPFLIT<%=cidx%>_FwdTxnID;
    wire [<%=bundle.interfaces.chiInt.params.FwdNID%>-1:0]      TXSNPFLIT<%=cidx%>_FwdNID;
    wire [<%=bundle.interfaces.chiInt.params.TxnID%>-1:0]       TXSNPFLIT<%=cidx%>_TxnID;
    wire [<%=bundle.interfaces.chiInt.params.SrcID%>-1:0]       TXSNPFLIT<%=cidx%>_SrcID;
    wire [<%=bundle.interfaces.chiInt.params.wQos%>-1:0]        TXSNPFLIT<%=cidx%>_QoS;

    <% if (bundle.fnNativeInterface === "CHI-A") { %>
    assign {RXREQFLIT<%=cidx%>_ExCompAck, RXREQFLIT<%=cidx%>_Excl, RXREQFLIT<%=cidx%>_LPID,
            RXREQFLIT<%=cidx%>_SnpAttr, RXREQFLIT<%=cidx%>_MemAttr, RXREQFLIT<%=cidx%>_PCrdType,
            RXREQFLIT<%=cidx%>_Order, RXREQFLIT<%=cidx%>_AllowRetry, RXREQFLIT<%=cidx%>_LikelyShared,
            RXREQFLIT<%=cidx%>_NS, RXREQFLIT<%=cidx%>_Addr, RXREQFLIT<%=cidx%>_Size, RXREQFLIT<%=cidx%>_Opcode,
            RXREQFLIT<%=cidx%>_TxnID, RXREQFLIT<%=cidx%>_SrcID, RXREQFLIT<%=cidx%>_TgtID, RXREQFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_req_flit;

	    assign RXREQFLIT<%=cidx%>_ReturnTxnID = 0; 
	    assign RXREQFLIT<%=cidx%>_StashNIDValid = 0;
	    assign RXREQFLIT<%=cidx%>_ReturnNID = 0;				   

    assign {RXRSPFLIT<%=cidx%>_PCrdType, RXRSPFLIT<%=cidx%>_DBID,
            RXRSPFLIT<%=cidx%>_Resp, RXRSPFLIT<%=cidx%>_RespErr,
            RXRSPFLIT<%=cidx%>_Opcode, RXRSPFLIT<%=cidx%>_TxnID, RXRSPFLIT<%=cidx%>_SrcID, RXRSPFLIT<%=cidx%>_TgtID, RXRSPFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_rsp_flit;

	    assign RXRSPFLIT<%=cidx%>_FwdState = 0;
						   
    assign {RXDATFLIT<%=cidx%>_Data, RXDATFLIT<%=cidx%>_BE,
            RXDATFLIT<%=cidx%>_DataID, RXDATFLIT<%=cidx%>_CCID, RXDATFLIT<%=cidx%>_DBID,
            RXDATFLIT<%=cidx%>_Resp, RXDATFLIT<%=cidx%>_RespErr,
            RXDATFLIT<%=cidx%>_Opcode, RXDATFLIT<%=cidx%>_TxnID,
            RXDATFLIT<%=cidx%>_SrcID, RXDATFLIT<%=cidx%>_TgtID, RXDATFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_dat_flit;

	    assign RXDATFLIT<%=cidx%>_FwdState = 0;
	    assign RXDATFLIT<%=cidx%>_HomenodeID = 0;
						   
    assign {TXRSPFLIT<%=cidx%>_PCrdType, TXRSPFLIT<%=cidx%>_DBID,
            TXRSPFLIT<%=cidx%>_Resp, TXRSPFLIT<%=cidx%>_RespErr, TXRSPFLIT<%=cidx%>_Opcode,
            TXRSPFLIT<%=cidx%>_TxnID, TXRSPFLIT<%=cidx%>_SrcID, TXRSPFLIT<%=cidx%>_TgtID, TXRSPFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_rsp_flit;

	    assign TXRSPFLIT<%=cidx%>_FwdState = 0;						   
						   
    assign {TXDATFLIT<%=cidx%>_Data, TXDATFLIT<%=cidx%>_BE,            
	    TXDATFLIT<%=cidx%>_DataID, TXDATFLIT<%=cidx%>_CCID, TXDATFLIT<%=cidx%>_DBID,
            TXDATFLIT<%=cidx%>_Resp, TXDATFLIT<%=cidx%>_RespErr, TXDATFLIT<%=cidx%>_Opcode,
            TXDATFLIT<%=cidx%>_TxnID, TXDATFLIT<%=cidx%>_SrcID, TXDATFLIT<%=cidx%>_TgtID, TXDATFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_dat_flit;

	    assign TXDATFLIT<%=cidx%>_FwdState = 0;
	    assign TXDATFLIT<%=cidx%>_HomenodeID = 0;
						   
    assign {TXSNPFLIT<%=cidx%>_NS, TXSNPFLIT<%=cidx%>_Addr, TXSNPFLIT<%=cidx%>_Opcode, 
            TXSNPFLIT<%=cidx%>_TxnID, TXSNPFLIT<%=cidx%>_SrcID, TXSNPFLIT<%=cidx%>_QoS} = 
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_snp_flit;

	    assign TXSNPFLIT<%=cidx%>_RetToSrc = 0; 
            assign TXSNPFLIT<%=cidx%>_DoNotGoToSD = 0;	
	    assign TXSNPFLIT<%=cidx%>_FwdTxnID = 0; 
            assign TXSNPFLIT<%=cidx%>_FwdNID = 0;
    <% } %>
			
    <% if (bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") { %>
    assign {RXREQFLIT<%=cidx%>_RSVDC, RXREQFLIT<%=cidx%>_TraceTag,
            RXREQFLIT<%=cidx%>_ExCompAck, RXREQFLIT<%=cidx%>_Excl, RXREQFLIT<%=cidx%>_LPID,
            RXREQFLIT<%=cidx%>_SnpAttr, RXREQFLIT<%=cidx%>_MemAttr, RXREQFLIT<%=cidx%>_PCrdType,
            RXREQFLIT<%=cidx%>_Order, RXREQFLIT<%=cidx%>_AllowRetry, RXREQFLIT<%=cidx%>_LikelyShared,
            RXREQFLIT<%=cidx%>_NS, RXREQFLIT<%=cidx%>_Addr, RXREQFLIT<%=cidx%>_Size, RXREQFLIT<%=cidx%>_Opcode,
            RXREQFLIT<%=cidx%>_ReturnTxnID, RXREQFLIT<%=cidx%>_StashNIDValid, RXREQFLIT<%=cidx%>_ReturnNID,
            RXREQFLIT<%=cidx%>_TxnID, RXREQFLIT<%=cidx%>_SrcID, RXREQFLIT<%=cidx%>_TgtID, RXREQFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_req_flit;
	
    assign {RXRSPFLIT<%=cidx%>_TraceTag, RXRSPFLIT<%=cidx%>_PCrdType, RXRSPFLIT<%=cidx%>_DBID,
            RXRSPFLIT<%=cidx%>_FwdState, RXRSPFLIT<%=cidx%>_Resp, RXRSPFLIT<%=cidx%>_RespErr,
            RXRSPFLIT<%=cidx%>_Opcode, RXRSPFLIT<%=cidx%>_TxnID, RXRSPFLIT<%=cidx%>_SrcID, RXRSPFLIT<%=cidx%>_TgtID, RXRSPFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_rsp_flit;
       
    assign {RXDATFLIT<%=cidx%>_Data, RXDATFLIT<%=cidx%>_BE, RXDATFLIT<%=cidx%>_TraceTag,
            RXDATFLIT<%=cidx%>_DataID, RXDATFLIT<%=cidx%>_CCID, RXDATFLIT<%=cidx%>_DBID,
            RXDATFLIT<%=cidx%>_FwdState, RXDATFLIT<%=cidx%>_Resp, RXDATFLIT<%=cidx%>_RespErr,
            RXDATFLIT<%=cidx%>_Opcode, RXDATFLIT<%=cidx%>_HomenodeID, RXDATFLIT<%=cidx%>_TxnID,
            RXDATFLIT<%=cidx%>_SrcID, RXDATFLIT<%=cidx%>_TgtID, RXDATFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_dat_flit;
 
    assign {TXRSPFLIT<%=cidx%>_TraceTag, TXRSPFLIT<%=cidx%>_PCrdType, TXRSPFLIT<%=cidx%>_DBID, TXRSPFLIT<%=cidx%>_FwdState,
            TXRSPFLIT<%=cidx%>_Resp, TXRSPFLIT<%=cidx%>_RespErr, TXRSPFLIT<%=cidx%>_Opcode,
            TXRSPFLIT<%=cidx%>_TxnID, TXRSPFLIT<%=cidx%>_SrcID, TXRSPFLIT<%=cidx%>_TgtID, TXRSPFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_rsp_flit;

    assign {TXDATFLIT<%=cidx%>_Data, TXDATFLIT<%=cidx%>_BE, TXDATFLIT<%=cidx%>_TraceTag,
            TXDATFLIT<%=cidx%>_DataID, TXDATFLIT<%=cidx%>_CCID, TXDATFLIT<%=cidx%>_DBID, TXDATFLIT<%=cidx%>_FwdState,
            TXDATFLIT<%=cidx%>_Resp, TXDATFLIT<%=cidx%>_RespErr, TXDATFLIT<%=cidx%>_Opcode, TXDATFLIT<%=cidx%>_HomenodeID,
            TXDATFLIT<%=cidx%>_TxnID, TXDATFLIT<%=cidx%>_SrcID, TXDATFLIT<%=cidx%>_TgtID, TXDATFLIT<%=cidx%>_QoS} =
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_dat_flit;

    assign {TXSNPFLIT<%=cidx%>_TraceTag, 
            TXSNPFLIT<%=cidx%>_RetToSrc, TXSNPFLIT<%=cidx%>_DoNotGoToSD, 
            TXSNPFLIT<%=cidx%>_NS, TXSNPFLIT<%=cidx%>_Addr, TXSNPFLIT<%=cidx%>_Opcode, 
            TXSNPFLIT<%=cidx%>_FwdTxnID, TXSNPFLIT<%=cidx%>_FwdNID, 
            TXSNPFLIT<%=cidx%>_TxnID, TXSNPFLIT<%=cidx%>_SrcID, TXSNPFLIT<%=cidx%>_QoS} = 
            `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_snp_flit;
    <% } %>
      
    <% if(obj.testBench == "emu") { %>
    always @(posedge `CHIAIU<%=cidx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
		if (clk_en) begin
	<% } else { %>
    always @(negedge `CHIAIU<%=cidx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
	<% } %>
    // CHI interface of CHI_AIU unit
        // RXREQ channel
        if (`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_req_flitv) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                0,
                $time,
                <%=unitID%>,
                RXREQFLIT<%=cidx%>_TraceTag,
                RXREQFLIT<%=cidx%>_ExCompAck, 
                RXREQFLIT<%=cidx%>_Excl, 
                RXREQFLIT<%=cidx%>_LPID, 
                RXREQFLIT<%=cidx%>_SnpAttr,
                RXREQFLIT<%=cidx%>_MemAttr, 
                RXREQFLIT<%=cidx%>_PCrdType, 
                RXREQFLIT<%=cidx%>_Order, 
                RXREQFLIT<%=cidx%>_AllowRetry, 
                RXREQFLIT<%=cidx%>_LikelyShared,
                RXREQFLIT<%=cidx%>_NS, 
                RXREQFLIT<%=cidx%>_Addr, 
                RXREQFLIT<%=cidx%>_Size, 
                RXREQFLIT<%=cidx%>_Opcode, 
                RXREQFLIT<%=cidx%>_ReturnTxnID, 
                RXREQFLIT<%=cidx%>_StashNIDValid,
                RXREQFLIT<%=cidx%>_ReturnNID, 
                RXREQFLIT<%=cidx%>_TxnID, 
                RXREQFLIT<%=cidx%>_SrcID, 
                RXREQFLIT<%=cidx%>_TgtID, 
                RXREQFLIT<%=cidx%>_QoS  
            );
        end

        // RXRSP channel
        if (`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_rsp_flitv) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                1,
                $time,
                <%=unitID%>,
//                `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_rsp_flit
                RXRSPFLIT<%=cidx%>_TraceTag,
                RXRSPFLIT<%=cidx%>_PCrdType,
                RXRSPFLIT<%=cidx%>_DBID,
                RXRSPFLIT<%=cidx%>_FwdState,
                RXRSPFLIT<%=cidx%>_Resp,
                RXRSPFLIT<%=cidx%>_RespErr,
                RXRSPFLIT<%=cidx%>_Opcode,
                RXRSPFLIT<%=cidx%>_TxnID, 
                RXRSPFLIT<%=cidx%>_SrcID, 
                RXRSPFLIT<%=cidx%>_TgtID, 
                RXRSPFLIT<%=cidx%>_QoS
	     );
        end

        // RXDAT channel
        if (`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_dat_flitv) begin
	    $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",   
                2,
                $time,
                <%=unitID%>,
		RXDATFLIT<%=cidx%>_TraceTag,
                RXDATFLIT<%=cidx%>_Data,
                RXDATFLIT<%=cidx%>_BE,
                RXDATFLIT<%=cidx%>_DBID,
                RXDATFLIT<%=cidx%>_CCID,
                RXDATFLIT<%=cidx%>_DataID,
                RXDATFLIT<%=cidx%>_HomenodeID,
                RXDATFLIT<%=cidx%>_FwdState,
                RXDATFLIT<%=cidx%>_Resp,
                RXDATFLIT<%=cidx%>_RespErr,
                RXDATFLIT<%=cidx%>_Opcode,
                RXDATFLIT<%=cidx%>_TxnID, 
                RXDATFLIT<%=cidx%>_SrcID, 
                RXDATFLIT<%=cidx%>_TgtID, 
                RXDATFLIT<%=cidx%>_QoS            
            );
        end

        // TXRSP channel
        if (`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_rsp_flitv) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                4,
                $time,
                <%=unitID%>,
                TXRSPFLIT<%=cidx%>_TraceTag,
                TXRSPFLIT<%=cidx%>_PCrdType,
                TXRSPFLIT<%=cidx%>_DBID,
                TXRSPFLIT<%=cidx%>_FwdState,
                TXRSPFLIT<%=cidx%>_Resp,
                TXRSPFLIT<%=cidx%>_RespErr,
                TXRSPFLIT<%=cidx%>_Opcode,
                TXRSPFLIT<%=cidx%>_TxnID, 
                TXRSPFLIT<%=cidx%>_SrcID, 
                TXRSPFLIT<%=cidx%>_TgtID, 
                TXRSPFLIT<%=cidx%>_QoS
              );
        end

        // TXDAT channel
        if (`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_dat_flitv) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h", 
                5, 
	        $time, 
	        <%=unitID%>, 
                TXDATFLIT<%=cidx%>_TraceTag,
                TXDATFLIT<%=cidx%>_Data,
                TXDATFLIT<%=cidx%>_BE,
                TXDATFLIT<%=cidx%>_DBID,
                TXDATFLIT<%=cidx%>_CCID,
                TXDATFLIT<%=cidx%>_DataID,
                TXDATFLIT<%=cidx%>_HomenodeID,
                TXDATFLIT<%=cidx%>_FwdState,
                TXDATFLIT<%=cidx%>_Resp,
                TXDATFLIT<%=cidx%>_RespErr,
                TXDATFLIT<%=cidx%>_Opcode,
                TXDATFLIT<%=cidx%>_TxnID, 
                TXDATFLIT<%=cidx%>_SrcID, 
                TXDATFLIT<%=cidx%>_TgtID, 
                TXDATFLIT<%=cidx%>_QoS
	    );
        end

        // TXSNP channel
        if (`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_snp_flitv) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                6,
                $time,
                <%=unitID%>,
                TXSNPFLIT<%=cidx%>_TraceTag,
                TXSNPFLIT<%=cidx%>_RetToSrc, 
                TXSNPFLIT<%=cidx%>_DoNotGoToSD,         
                TXSNPFLIT<%=cidx%>_NS, 
                TXSNPFLIT<%=cidx%>_Addr, 
                TXSNPFLIT<%=cidx%>_Opcode, 
                TXSNPFLIT<%=cidx%>_FwdTxnID, 
                TXSNPFLIT<%=cidx%>_FwdNID,
                TXSNPFLIT<%=cidx%>_TxnID, 
                TXSNPFLIT<%=cidx%>_SrcID, 
                TXSNPFLIT<%=cidx%>_QoS		      
         );
        end

     // SMI interface 
    <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
    <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
         // TX-DP port
         if (`CHIAIU<%=cidx%>.smi_tx<%=i%>_dp_valid && `CHIAIU<%=cidx%>.smi_tx<%=i%>_dp_ready) begin 
            <% smi_id = (1 << 24 | 26 << 16 | cidx << 8 | i ); %>       
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                26,
                $time,
                <%=unitID%>, 
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_dp_data, 
		`CHIAIU<%=cidx%>.smi_tx<%=i%>_dp_user,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_dp_last,
                <%=smi_id%>
            );
         end
     <% } %>
         // TX-NDP port
         if (`CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_valid && `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_ready) begin
             <% smi_id = (1 << 24 | 24 << 16 | cidx << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                24,
                $time,
                <%=unitID%>,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_ndp_len,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_targ_id,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_src_id,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_id,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_ndp,
                `CHIAIU<%=cidx%>.smi_tx<%=i%>_ndp_dp_present,
                <%=smi_id%>
            );
         end
    <% } %> 

    <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
    <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>
         // RX-DP port
         if (`CHIAIU<%=cidx%>.smi_rx<%=i%>_dp_valid && `CHIAIU<%=cidx%>.smi_rx<%=i%>_dp_ready) begin  
            <% smi_id = (1 << 24 | 27 << 16 | cidx << 8 | i ); %>      
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                27,
                $time,
                <%=unitID%>,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_dp_data, 
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_dp_user,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_dp_last,
                <%=smi_id%>
            );
         end
    <% } %>
         // RX-NDP port
         if (`CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_valid && `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_ready) begin
            <% smi_id = (1 << 24 | 25 << 16 | cidx << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                25,
                $time,
                <%=unitID%>,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_ndp_len,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_targ_id,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_src_id,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_id,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_ndp,
                `CHIAIU<%=cidx%>.smi_rx<%=i%>_ndp_dp_present,
                <%=smi_id%>
            );
         end
    <% } %>
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>
    end // always @ (negedge `CHIAIU<%=cidx%>.<%=bundle.interfaces.clkInt.name%>clk)

   //RX-Link and Tx-link are combinatorial
   always @(`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_link_active_req or `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_link_active_ack) begin
       // RX-link channel
       $fdisplay(file_handle, "%0h:%0h:%0h:%0h",
           8,
           $time,
           <%=unitID%>,
           {bit'(`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_link_active_req), bit'(`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>rx_link_active_ack)}
       );
   end
 
   always @(`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_link_active_req or `CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_link_active_ack) begin
       // TX-link channel
       $fdisplay(file_handle, "%0h:%0h:%0h:%0h",
           9,
           $time,
           <%=unitID%>,
           {bit'(`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_link_active_req), bit'(`CHIAIU<%=cidx%>.<%=bundle.interfaces.chiInt.name%>tx_link_active_ack)}
       );
   end
   <% cidx++; %>
<% } else { %>
//////////////////////////////////
// IOAIU unit
/////////////////////////////////

<% var aiu_axiInt;    %>
<% var aiu_NumCores;  %>
<%  unitID = indx; %>

<%  let axiIsArray = Array.isArray(bundle.interfaces.axiInt);
    if (axiIsArray) {
       aiu_NumCores = bundle.interfaces.axiInt.length;
    } else {
       aiu_NumCores = 1;
    }
    aiu_axiInt = new Array(aiu_NumCores);
    aiu_axiInt[0] = axiIsArray ? bundle.interfaces.axiInt[0] : bundle.interfaces.axiInt;
    for (var i=1; i<aiu_NumCores; i++) {
       aiu_axiInt[i] = bundle.interfaces.axiInt[i];
    }
%>


<% var i = 0;    %>
<% for (var i=0; i<aiu_NumCores; i++) { %>
<% ncidxx = ncidx+i %>
<%   if (bundle.useCache == 1) { %> 
    <% if(obj.testBench == "emu") { %>
	`define IOAIU_CCP<%=ncidxx%>_<%=i%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top
    always @(posedge ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk) begin /*`IOAIU_CCP<%=i%> is the hierarchical path*/
	    if (clk_en) begin
	<% } else { %>
<% if (bundle.hierPath && bundle.hierPath!=='') {%>
    `define IOAIU_CCP<%=ncidxx%>_<%=i%> tb_top.dut.<%=bundle.instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top
<%}else{%>
    `define IOAIU_CCP<%=ncidxx%>_<%=i%> tb_top.dut.<%=bundle.strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top
<% } %>
    always @(negedge tb_top.dut.<%=bundle.unitClk[0]%>clk) begin /*`IOAIU_CCP<%=i%> is the hierarchical path*/
	<% } %>
        if (`IOAIU_CCP<%=ncidxx%>_<%=i%>.ctrl_op_valid_p0 && `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_op_ready_p0) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h",
                64,
                $time,
                <%=unitID%>,
                `IOAIU_CCP<%=ncidxx%>_<%=i%>.ctrl_op_address_p0,
                `IOAIU_CCP<%=ncidxx%>_<%=i%>.ctrl_op_security_p0,
                <%=i%>
            );
        end
        if (`IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_valid_p2) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                65,
                $time,
                <%=unitID%>,
                `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_current_state_p2,
                `IOAIU_CCP<%=ncidxx%>_<%=i%>.ctrl_op_state_p2,
                {     `IOAIU_CCP<%=ncidxx%>_<%=i%>.ctrl_op_write_data_p2, `IOAIU_CCP<%=ncidxx%>_<%=i%>.ctrl_op_read_data_p2, 
                      `IOAIU_CCP<%=ncidxx%>_<%=i%>.ctrl_op_allocate_p2, `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_nack_no_allocate_p2,
                      `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_nack_ce_p2, `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_nack_uce_p2,
                      `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_nack_p2
                },
                <%=i%>
            );
        end
        if (`IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_evict_valid_p2) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                66,
                $time,
                <%=unitID%>,
                `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_evict_address_p2,
                `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_evict_security_p2, 
                `IOAIU_CCP<%=ncidxx%>_<%=i%>.cache_evict_state_p2,
                <%=i%>
            );
        end
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>

    end // always @ (negedge tb_top.dut.<%=bundle.unitClk[0]%>clk)
    `undef IOSIU_CCP<%=ncidxx%>_<%=i%>
<% } %>
    <% if(obj.testBench == "emu") { %>
	`define IOAIU<%=ncidxx%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>
    always @(posedge ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk) begin
		if (clk_en) begin
	<% } else { %>
<% if (bundle.hierPath && bundle.hierPath!=='') {%>
    `define IOAIU<%=ncidxx%> tb_top.dut.<%=bundle.instancePath%>
<%}else{%>
    `define IOAIU<%=ncidxx%> tb_top.dut.<%=bundle.strRtlNamePrefix%>
<% } %>
    always @(negedge tb_top.dut.<%=bundle.unitClk[0]%>clk) begin
	<% } %>
        // AXI or ACE interface
        // ar channel
        // zero for region, domain, snoop, bar
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                12,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_id,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_addr,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_len,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_size,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_burst,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_lock,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_cache,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_prot,
                <% if (aiu_axiInt[i].params.wQos > 0) { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_qos <% } else { %> 0 <% } %>,
                0, // region
                <% if (aiu_axiInt[i].params.wArUser > 0) { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_user <% } else { %> 0 <% } %>,
                <% if (aiu_axiInt[i].name == "ace_slv_") { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_domain <% } else { %> 0 <% } %>,
                <% if (aiu_axiInt[i].name == "ace_slv_") { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_snoop <% } else { %> 0 <% } %>,
                <% if (aiu_axiInt[i].name == "ace_slv_") { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ar_bar <% } else { %> 0 <% } %>,
                <%=i%>
            );
        end

        // aw channel
        // zero for region, domain, snoop, bar, unique
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                13,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_id,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_addr,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_len,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_size,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_burst,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_lock,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_cache,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_prot,
                <% if (aiu_axiInt[i].params.wQos > 0) { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_qos <% } else { %> 0 <% } %>,
                0, // region
                <% if (aiu_axiInt[i].params.wAwUser > 0) { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_user <% } else { %> 0 <% } %>,
                <% if (aiu_axiInt[i].name == "ace_slv_") { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_domain <% } else { %> 0 <% } %>,
                <% if (aiu_axiInt[i].name == "ace_slv_") { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_snoop <% } else { %> 0 <% } %>,
                <% if (aiu_axiInt[i].name == "ace_slv_") { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_bar <% } else { %> 0 <% } %>,
		0, // xunique
	        <% if (aiu_axiInt[i].params.eAtomic > 0) { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_atop <% } else { %> 0 <% } %>, // awatop for atomics	      
                <%=i%>
            );
        end // if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>aw_ready)
	    
        // w channel
        // zero for wuser
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>w_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>w_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                14,
                $time,
                <%=unitID%>,
                0,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>w_data,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>w_strb,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>w_last,
                <%=i%>
            );
        end
        // b channel
        // zero for buser
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>b_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>b_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                15,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>b_id,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>b_resp,
                0,
                <%=i%>
            );
        end
        // r channel
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>r_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>r_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                16,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>r_id,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>r_resp,
                <% if (aiu_axiInt[i].params.wRUser > 0) { %> `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>r_user <% } else { %> 0 <% } %>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>r_data,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>r_last,
                <%=i%>
           );
        end     
<% if (aiu_axiInt[i].params.eAc ) { %>
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ac_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ac_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                17,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ac_addr,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ac_snoop,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>ac_prot,
                <%=i%>
           );
        end     
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>cr_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>cr_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h",
                18,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>cr_resp,
                <%=i%>
           );
        end     
<% } %>
<% if (bundle.fnNativeInterface === "ACE") { %>
        if (`IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>cd_valid && `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>cd_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h",
                19,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>cd_data,
                `IOAIU<%=ncidxx%>.<%=aiu_axiInt[i].name%>cd_last,
                <%=i%>
           );
        end     
<% } %>

	<% if(obj.testBench == "emu") { %>
	end
	<% } %>

    end // always @ (negedge tb_top.dut.<%=bundle.unitClk[0]%>clk)
<% } %>

    // SMI interface
    //`define IOAIU<%=ncidx%>_core tb_top.dut.<%=bundle.strRtlNamePrefix%>.ioaiu_core

    <% if(obj.testBench == "emu") { %>
    <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
        <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
        <% smi_id = (2 << 24 | 26 << 16 | ncidx << 8 | i ); %>

		//logic [WSMIDPBE-1 : 0]       smi_tx<%=i%>_dp_be_<%=ncidx%>;
		//logic                        smi_tx<%=i%>_dp_protection_<%=ncidx%>;
		//logic [WSMIDPDWID-1:0]       smi_tx<%=i%>_dp_dwid_<%=ncidx%>;
		//logic [WSMIDPDBAD-1:0]       smi_tx<%=i%>_dp_dbad_<%=ncidx%>;
		//logic                        smi_tx<%=i%>_dp_concuser_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_tx<%=i%>_msg_id_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_tx<%=i%>_rmsg_id_<%=ncidx%>;
		//logic [WSMIRBID-1:0]         smi_tx<%=i%>_rbid_<%=ncidx%>;
		//logic [WSMIADDR-1:0]         smi_tx<%=i%>_addr_<%=ncidx%>;
		//logic [WSMINS-1:0]           smi_tx<%=i%>_ns_<%=ncidx%>;
        //logic [WSMINCOREUNITID-1:0]  smi_tx<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>;
        //logic [WSMIMSGID-1:0]        smi_tx<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>;

		// TX-DP port
	    ioaiu_smi_bfm_<%=smi_index%> ioaiu_smi_bfm_<%=smi_index%> (ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk, 
                                       26,
                                       <%=unitID%>,		      
	                                  `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_valid, 
	    							  `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_ready,
	    							  `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_last,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_data,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_user,
                                      <% if (obj.AiuInfo[0].useResiliency) { %>
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                                      <% } else { %>
	    					          0,
                                      <% } %>
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_targ_id,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_src_id,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_type,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp_len,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_dp_present,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_id,
					                  <%=smi_id%>,
							          <%=smi_index%>,
							          0
									  //smi_tx<%=i%>_dp_be_<%=ncidx%>, 
								      //smi_tx<%=i%>_dp_protection_<%=ncidx%>, 
								      //smi_tx<%=i%>_dp_dwid_<%=ncidx%>, 
								      //smi_tx<%=i%>_dp_dbad_<%=ncidx%>, 
								      //smi_tx<%=i%>_dp_concuser_<%=ncidx%>, 
								      //smi_tx<%=i%>_msg_id_<%=ncidx%>, 
								      //smi_tx<%=i%>_rmsg_id_<%=ncidx%>, 
								      //smi_tx<%=i%>_rbid_<%=ncidx%>, 
								      //smi_tx<%=i%>_addr_<%=ncidx%>, 
								      //smi_tx<%=i%>_ns_<%=ncidx%>,
                                      //smi_tx<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>,
                                      //smi_tx<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>
							  		  );
		<% smi_index = smi_index + 1 %>
	    <% } %>
        <% smi_id = (2 << 24 | 24 << 16 | ncidx << 8 | i ); %>

		//logic [WSMIDPBE-1 : 0]       smi_tx_ndp<%=i%>_dp_be_<%=ncidx%>;
		//logic                        smi_tx_ndp<%=i%>_dp_protection_<%=ncidx%>;
		//logic [WSMIDPDWID-1:0]       smi_tx_ndp<%=i%>_dp_dwid_<%=ncidx%>;
		//logic [WSMIDPDBAD-1:0]       smi_tx_ndp<%=i%>_dp_dbad_<%=ncidx%>;
		//logic                        smi_tx_ndp<%=i%>_dp_concuser_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_tx_ndp<%=i%>_msg_id_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_tx_ndp<%=i%>_rmsg_id_<%=ncidx%>;
		//logic [WSMIRBID-1:0]         smi_tx_ndp<%=i%>_rbid_<%=ncidx%>;
		//logic [WSMIADDR-1:0]         smi_tx_ndp<%=i%>_addr_<%=ncidx%>;
		//logic [WSMINS-1:0]           smi_tx_ndp<%=i%>_ns_<%=ncidx%>;
        //logic [WSMINCOREUNITID-1:0]  smi_tx_ndp<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>;
        //logic [WSMIMSGID-1:0]        smi_tx_ndp<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>;

		// TX-NDP port
	    ioaiu_smi_bfm_<%=smi_index%> ioaiu_smi_bfm_<%=smi_index%> (ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk, 
                                      24,
                                      <%=unitID%>,		      
	                                  `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_valid, 
	    							  `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_ready,
	    							  0, //`IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_last,
                                      0, //`IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_data,
                                      0, //`IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_user,
                                      <% if (obj.AiuInfo[0].useResiliency) { %>
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                                      <% } else { %>
	    					          0,
                                      <% } %>
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_targ_id,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_src_id,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_type,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp_len,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_dp_present,
                                      `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_id,
					                  <%=smi_id%>,
							          <%=smi_index%>,
							          1
									  //smi_tx_ndp<%=i%>_dp_be_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_dp_protection_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_dp_dwid_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_dp_dbad_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_dp_concuser_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_msg_id_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_rmsg_id_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_rbid_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_addr_<%=ncidx%>, 
								      //smi_tx_ndp<%=i%>_ns_<%=ncidx%>,
                                      //smi_tx_ndp<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>,
                                      //smi_tx_ndp<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>
							  		  );

	<% smi_index = smi_index + 1 %>
    <% } %>


    <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
    <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>

		//logic [WSMIDPBE-1 : 0]       smi_rx<%=i%>_dp_be_<%=ncidx%>;
		//logic                        smi_rx<%=i%>_dp_protection_<%=ncidx%>;
		//logic [WSMIDPDWID-1:0]       smi_rx<%=i%>_dp_dwid_<%=ncidx%>;
		//logic [WSMIDPDBAD-1:0]       smi_rx<%=i%>_dp_dbad_<%=ncidx%>;
		//logic                        smi_rx<%=i%>_dp_concuser_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_rx<%=i%>_msg_id_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_rx<%=i%>_rmsg_id_<%=ncidx%>;
		//logic [WSMIRBID-1:0]         smi_rx<%=i%>_rbid_<%=ncidx%>;
		//logic [WSMIADDR-1:0]         smi_rx<%=i%>_addr_<%=ncidx%>;
		//logic [WSMINS-1:0]           smi_rx<%=i%>_ns_<%=ncidx%>;
        //logic [WSMINCOREUNITID-1:0]  smi_rx<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>;
        //logic [WSMIMSGID-1:0]        smi_rx<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>;

        // RX-DP port
        <% smi_id = (2 << 24 | 26 << 16 | ncidx << 8 | i ); %>
	    ioaiu_smi_bfm_rx_<%=smi_index_rx%> ioaiu_smi_bfm_rx_<%=smi_index_rx%> (ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk, 
                                       27,
                                       <%=unitID%>,		      
	                                  `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_valid, 
	    							  `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_ready,
	    							  `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_last,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_data,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_user,
                                      <% if (obj.AiuInfo[0].useResiliency) { %>
                                      <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                                      <% } else { %>
	    					          0,
                                      <% } %>
                                      <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_targ_id,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_src_id,
                                      <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_type,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp_len,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_dp_present,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_id,
					                  <%=smi_id%>,
							          <%=smi_index_rx%>,
							          0
									  //smi_rx<%=i%>_dp_be_<%=ncidx%>, 
								      //smi_rx<%=i%>_dp_protection_<%=ncidx%>, 
								      //smi_rx<%=i%>_dp_dwid_<%=ncidx%>, 
								      //smi_rx<%=i%>_dp_dbad_<%=ncidx%>, 
								      //smi_rx<%=i%>_dp_concuser_<%=ncidx%>, 
								      //smi_rx<%=i%>_msg_id_<%=ncidx%>, 
								      //smi_rx<%=i%>_rmsg_id_<%=ncidx%>, 
								      //smi_rx<%=i%>_rbid_<%=ncidx%>, 
								      //smi_rx<%=i%>_addr_<%=ncidx%>, 
								      //smi_rx<%=i%>_ns_<%=ncidx%>,
                                      //smi_rx<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>,
                                      //smi_rx<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>
							  		  );
		<% smi_index_rx = smi_index_rx + 1 %>
	    <% } %>
        <% smi_id = (2 << 24 | 24 << 16 | ncidx << 8 | i ); %>

		//logic [WSMIDPBE-1 : 0]       smi_rx_ndp<%=i%>_dp_be_<%=ncidx%>;
		//logic                        smi_rx_ndp<%=i%>_dp_protection_<%=ncidx%>;
		//logic [WSMIDPDWID-1:0]       smi_rx_ndp<%=i%>_dp_dwid_<%=ncidx%>;
		//logic [WSMIDPDBAD-1:0]       smi_rx_ndp<%=i%>_dp_dbad_<%=ncidx%>;
		//logic                        smi_rx_ndp<%=i%>_dp_concuser_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_rx_ndp<%=i%>_msg_id_<%=ncidx%>;
		//logic [WSMIMSGID-1:0]        smi_rx_ndp<%=i%>_rmsg_id_<%=ncidx%>;
		//logic [WSMIRBID-1:0]         smi_rx_ndp<%=i%>_rbid_<%=ncidx%>;
		//logic [WSMIADDR-1:0]         smi_rx_ndp<%=i%>_addr_<%=ncidx%>;
		//logic [WSMINS-1:0]           smi_rx_ndp<%=i%>_ns_<%=ncidx%>;
        //logic [WSMINCOREUNITID-1:0]  smi_rx_ndp<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>;
        //logic [WSMIMSGID-1:0]        smi_rx_ndp<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>;

		// RX-NDP port
	    ioaiu_smi_bfm_rx_<%=smi_index_rx%> ioaiu_smi_bfm_rx_<%=smi_index_rx%> (ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk, 
                                      25,
                                      <%=unitID%>,		      
	                                  `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_valid, 
	    							  `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_ready,
	    							  0, //`IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_last,
                                      0, //`IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_data,
                                      0, //`IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_user,
                                      <% if (obj.AiuInfo[0].useResiliency) { %>
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                                      <% } else { %>
	    					          0,
                                      <% } %>
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_targ_id,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_src_id,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                                      <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_type,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp_len,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_dp_present,
                                      `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_id,
					                  <%=smi_id%>,
							          <%=smi_index_rx%>,
							          1
									  //smi_rx_ndp<%=i%>_dp_be_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_dp_protection_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_dp_dwid_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_dp_dbad_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_dp_concuser_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_msg_id_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_rmsg_id_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_rbid_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_addr_<%=ncidx%>, 
								      //smi_rx_ndp<%=i%>_ns_<%=ncidx%>,
                                      //smi_rx_ndp<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>,
                                      //smi_rx_ndp<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>
							  		  );

	<% smi_index_rx = smi_index_rx + 1 %>
    <% } %>


	always @(posedge ncore_hdl_top.dut.<%=bundle.unitClk[0]%>clk) begin
		if (clk_en) begin
	<% } else { %>
    always @(negedge tb_top.dut.<%=bundle.unitClk[0]%>clk) begin
	<% } %>
    <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
    <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
      // TX-DP port
        if (`IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_valid && `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_ready) begin
            <% if(obj.testBench!="emu") { %>
                ioaiu<%=ncidx%>_smi_agent_pkg::smi_seq_item ioaiu<%=ncidx%>_smi_pkt;
                ioaiu<%=ncidx%>_smi_pkt                = ioaiu<%=ncidx%>_smi_agent_pkg::smi_seq_item::type_id::create("smi_pkt_<%=ncidx%>_tx<%=i%>");
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_ready   = 1;
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_last    = `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_last;
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_data    = new [1];
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_data[0] = `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_data;
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_user    = new [1];
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_user[0] = `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_user;
                ioaiu<%=ncidx%>_smi_pkt.smi_steer      = <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_targ_id    = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_targ_id;
                ioaiu<%=ncidx%>_smi_pkt.smi_src_id     = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_src_id;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_tier   = <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_qos    = <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_pri    = <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_type   = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_type;
                ioaiu<%=ncidx%>_smi_pkt.smi_ndp_len    = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp_len;
                ioaiu<%=ncidx%>_smi_pkt.smi_ndp        = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp;
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_present = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_dp_present;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_id     = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_id;
                <% if (obj.AiuInfo[0].useResiliency) { %>
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 'h0 <% } %>;
                <% } else { %>
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = 'h0;
                <% } %>
			    					  
	            ioaiu<%=ncidx%>_smi_pkt.unpack_dp_smi_seq_item();
	            ioaiu<%=ncidx%>_smi_pkt.unpack_smi_seq_item();
            <% } %> 
            <% smi_id = (2 << 24 | 26 << 16 | ncidx << 8 | i ); %>
            <% if(obj.testBench!="emu") { %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                26,
                $time,
                <%=unitID%>,		      
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_data, 
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_user,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_last,
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_be[0],
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_protection[0],
		        ioaiu<%=ncidx%>_smi_pkt.smi_dp_dwid[0],
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_dbad[0],
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_concuser[0],
		        ioaiu<%=ncidx%>_smi_pkt.smi_msg_id,
	            ioaiu<%=ncidx%>_smi_pkt.smi_rmsg_id,
	            ioaiu<%=ncidx%>_smi_pkt.smi_rbid,
                <%=smi_id%>		      
            );
			<% } else { %>
            if ($test$plusargs ("ioaiu_smi_tempo")) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                26,
                $time,
                <%=unitID%>,		      
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_data, 
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_user,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_dp_last,
				//smi_tx<%=i%>_dp_be_<%=ncidx%>, 
				//smi_tx<%=i%>_dp_protection_<%=ncidx%>, 
				//smi_tx<%=i%>_dp_dwid_<%=ncidx%>, 
				//smi_tx<%=i%>_dp_dbad_<%=ncidx%>, 
				//smi_tx<%=i%>_dp_concuser_<%=ncidx%>, 
				//smi_tx<%=i%>_msg_id_<%=ncidx%>, 
				//smi_tx<%=i%>_rmsg_id_<%=ncidx%>, 
				//smi_tx<%=i%>_rbid_<%=ncidx%>, 
				<%=smi_id%>
            );
            end
            <% } %> 
        end
    <% } %>
      // TX-NDP port								     
        if (`IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_valid && `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_ready) begin
            <% if(obj.testBench!="emu") { %>
                ioaiu<%=ncidx%>_smi_agent_pkg::smi_seq_item ioaiu<%=ncidx%>_smi_pkt;
	            ioaiu<%=ncidx%>_smi_pkt = new();
                ioaiu<%=ncidx%>_smi_pkt.smi_steer      = <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_targ_id    = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_targ_id;
                ioaiu<%=ncidx%>_smi_pkt.smi_src_id     = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_src_id;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_tier   = <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_qos    = <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_pri    = <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_type   = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_type;
                ioaiu<%=ncidx%>_smi_pkt.smi_ndp_len    = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp_len;
                ioaiu<%=ncidx%>_smi_pkt.smi_ndp        = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp;
                ioaiu<%=ncidx%>_smi_pkt.smi_dp_present = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_dp_present;
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_id     = `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_id;
                <% if (obj.AiuInfo[0].useResiliency) { %>
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 'h0 <% } %>;
                <% } else { %>
                ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = 'h0;
                <% } %>
	            ioaiu<%=ncidx%>_smi_pkt.unpack_smi_seq_item();
            <% } %> 
            <% smi_id = (2 << 24 | 24 << 16 | ncidx << 8 | i ); %>
            <% if(obj.testBench!="emu") { %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                24,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp_len,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_targ_id,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_src_id,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_id,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp, 
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_dp_present,
	            ioaiu<%=ncidx%>_smi_pkt.smi_addr,
	            ioaiu<%=ncidx%>_smi_pkt.smi_ns,
		        ioaiu<%=ncidx%>_smi_pkt.smi_rmsg_id,
		        ioaiu<%=ncidx%>_smi_pkt.smi_rbid,
                <%=smi_id%>		      
            );
			<% } else { %>
            if ($test$plusargs ("ioaiu_smi_tempo")) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                24,
                $time,
                <%=unitID%>,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp_len,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_targ_id,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_src_id,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_id,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_ndp, 
                `IOAIU<%=ncidx%>.smi_tx<%=i%>_ndp_dp_present,
				//smi_tx_ndp<%=i%>_addr_<%=ncidx%>, 
				//smi_tx_ndp<%=i%>_ns_<%=ncidx%>,
				//smi_tx_ndp<%=i%>_rmsg_id_<%=ncidx%>, 
				//smi_tx_ndp<%=i%>_rbid_<%=ncidx%>, 
                <%=smi_id%>
            );
            end
            <% } %> 
        end
    <% } %> 

    <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
    <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>
        // RX-DP port
        if (`IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_valid && `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_ready) begin
        <% if(obj.testBench!="emu") { %>
            ioaiu<%=ncidx%>_smi_agent_pkg::smi_seq_item ioaiu<%=ncidx%>_smi_pkt;
	        ioaiu<%=ncidx%>_smi_pkt = new();
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_ready   = 1;
            ioaiu<%=ncidx%>_smi_pkt.smi_steer      = <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_targ_id    = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_targ_id;
            ioaiu<%=ncidx%>_smi_pkt.smi_src_id     = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_src_id;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_tier   = <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_qos    = <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_pri    = <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_type   = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_type;
            ioaiu<%=ncidx%>_smi_pkt.smi_ndp_len    = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp_len;
            ioaiu<%=ncidx%>_smi_pkt.smi_ndp        = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp;
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_present = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_dp_present;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_id     = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_id;
            <% if (obj.AiuInfo[0].useResiliency) { %>
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 'h0 <% } %>;
            <% } else { %>
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = 'h0;
            <% } %>
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_last    = `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_last;
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_data    = new [1];
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_data[0] = `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_data;
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_user    = new [1];
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_user[0] = `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_user;
	        ioaiu<%=ncidx%>_smi_pkt.unpack_dp_smi_seq_item();
	        ioaiu<%=ncidx%>_smi_pkt.unpack_smi_seq_item();
        <% } %> 
        <% smi_id = (2 << 24 | 27 << 16 | ncidx << 8 | i ); %>
        <% if(obj.testBench!="emu") { %>
        $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
            27,
            $time,
            <%=unitID%>,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_data, 
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_user,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_last,
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_be[0],
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_protection[0],
		        ioaiu<%=ncidx%>_smi_pkt.smi_dp_dwid[0],
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_dbad[0],
	            ioaiu<%=ncidx%>_smi_pkt.smi_dp_concuser[0],
	            ioaiu<%=ncidx%>_smi_pkt.smi_rmsg_id,
	            ioaiu<%=ncidx%>_smi_pkt.smi_rbid,
            <%=smi_id%>		      
        );
		<% } else { %>
            if ($test$plusargs ("ioaiu_smi_tempo")) begin
        $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
            27,
            $time,
            <%=unitID%>,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_data, 
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_user,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_dp_last,
			//smi_rx<%=i%>_dp_be_<%=ncidx%>, 
			//smi_rx<%=i%>_dp_protection_<%=ncidx%>, 
			//smi_rx<%=i%>_dp_dwid_<%=ncidx%>, 
			//smi_rx<%=i%>_dp_dbad_<%=ncidx%>, 
			//smi_rx<%=i%>_dp_concuser_<%=ncidx%>, 
			//smi_rx<%=i%>_rmsg_id_<%=ncidx%>, 
			//smi_rx<%=i%>_rbid_<%=ncidx%>, 
			<%=smi_id%>		      
        );
        end
        <% } %> 
         end
<% } %>
         // RX-NDP port
        if (`IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_valid && `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_ready) begin
        <% if(obj.testBench!="emu") { %>
            ioaiu<%=ncidx%>_smi_agent_pkg::smi_seq_item ioaiu<%=ncidx%>_smi_pkt;
    	    ioaiu<%=ncidx%>_smi_pkt = new();
            ioaiu<%=ncidx%>_smi_pkt.smi_steer      = <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_targ_id    = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_targ_id;
            ioaiu<%=ncidx%>_smi_pkt.smi_src_id     = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_src_id;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_tier   = <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_qos    = <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_pri    = <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_type   = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_type;
            ioaiu<%=ncidx%>_smi_pkt.smi_ndp_len    = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp_len;
            ioaiu<%=ncidx%>_smi_pkt.smi_ndp        = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp;
            ioaiu<%=ncidx%>_smi_pkt.smi_dp_present = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_dp_present;
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_id     = `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_id;
            <% if (obj.AiuInfo[0].useResiliency) { %>
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 'h0 <% } %>;
            <% } else { %>
            ioaiu<%=ncidx%>_smi_pkt.smi_msg_user   = 'h0;
            <% } %>
	        ioaiu<%=ncidx%>_smi_pkt.unpack_smi_seq_item();
        <% } %> 
        <% smi_id = (2 << 24 | 25 << 16 | ncidx << 8 | i ); %>
        <% if(obj.testBench!="emu") { %>
        $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
            25,
            $time,
            <%=unitID%>,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp_len,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_targ_id,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_src_id,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_id,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_type, 
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_dp_present,		      
	            ioaiu<%=ncidx%>_smi_pkt.smi_addr,
	            ioaiu<%=ncidx%>_smi_pkt.smi_ns,
                ioaiu<%=ncidx%>_smi_pkt.smi_rmsg_id,
		        ioaiu<%=ncidx%>_smi_pkt.smi_rbid,
            <%=smi_id%>,		      
		        ioaiu<%=ncidx%>_smi_pkt.smi_mpf1_dtr_tgt_id,
		        ioaiu<%=ncidx%>_smi_pkt.smi_mpf2_dtr_msg_id
	      
        );
		<% } else { %>
        if ($test$plusargs ("ioaiu_smi_tempo")) begin
        $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
            25,
            $time,
            <%=unitID%>,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp_len,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_targ_id,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_src_id,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_id,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_type, 
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_ndp,
            `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_dp_present,		      
			//smi_rx_ndp<%=i%>_addr_<%=ncidx%>, 
			//smi_rx_ndp<%=i%>_ns_<%=ncidx%>,
			//smi_rx_ndp<%=i%>_rmsg_id_<%=ncidx%>, 
			//smi_rx_ndp<%=i%>_rbid_<%=ncidx%>, 
            <%=smi_id%>
            //smi_rx_ndp<%=i%>_mpf1_dtr_tgt_id_<%=ncidx%>,
            //smi_rx_ndp<%=i%>_mpf2_dtr_msg_id_<%=ncidx%>
);
        end
        <% } %> 
        end // if (`IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_valid && `IOAIU<%=ncidx%>.smi_rx<%=i%>_ndp_msg_ready)
      <% } %> 
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>
     end // always @ (negedge tb_top.dut.<%=bundle.unitClk[0]%>clk)
    `undef IOAIU<%=ncidx%>
    <% ncidx++; %>
<% } %>
<% }); %>

// ==================================================
// AIU UNIT END
// ==================================================}

// {=================================================
// DCE UNIT START
// ==================================================
<% obj.DceInfo.forEach(function(bundle, indx) { %>
<% unitID = obj.AiuInfo.length + indx; %>
    // Directory interface
    <% if(obj.testBench == "emu") { %>
    `ifndef DCE_DM<%=unitID%>
          `define DCE_DM<%=unitID%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>.dce_func_unit.dce_dm
    `endif 
    `ifndef DCE<%=unitID%>
        `define DCE<%=unitID%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>
    `endif
    always @(posedge `DCE<%=unitID%>.<%=bundle.interfaces.clkInt.name%>clk) begin
		if (clk_en) begin
	<% } else { %>
    `ifndef DCE_DM<%=unitID%>
        <% if(bundle.hierPath && bundle.hierPath !== '') { %>
           `define DCE_DM<%=unitID%> tb_top.dut.<%=bundle.instancePath%>.dce_func_unit.dce_dm
        <%} else {%>
           `define DCE_DM<%=unitID%> tb_top.dut.<%=bundle.strRtlNamePrefix%>.dce_func_unit.dce_dm
        <%}%>
    `endif 
    `ifndef DCE<%=unitID%>
        <% if(bundle.hierPath && bundle.hierPath !== ''){ %>
            `define DCE<%=unitID%> tb_top.dut.<%=bundle.instancePath%>
        <%}else{%>
            `define DCE<%=unitID%> tb_top.dut.<%=bundle.strRtlNamePrefix%>
        <%}%>
    `endif
    always @(negedge `DCE<%=unitID%>.<%=bundle.interfaces.clkInt.name%>clk) begin
	<% } %>
        // CMD REQ 
        if (`DCE_DM<%=unitID%>.dm_cmd_req_ready_o && `DCE_DM<%=unitID%>.dm_cmd_req_valid_i) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h", 
                32,
                $time,
                <%=unitID%>,
                `DCE_DM<%=unitID%>.dm_cmd_req_addr_i,
                `DCE_DM<%=unitID%>.dm_cmd_req_ns_i,
                `DCE_DM<%=unitID%>.dm_cmd_req_type_i,
                `DCE_DM<%=unitID%>.dm_cmd_req_iid_i,
                $clog2(`DCE_DM<%=unitID%>.dm_cmd_req_att_vec_i),
                `DCE_DM<%=unitID%>.dm_cmd_req_sid_i,
    <% if(obj.testBench == "emu") { %>
		ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>.dce_func_unit.dm_req_mpf2
	<% } else { %>
              <% if(bundle.hierPath && bundle.hierPath !== '') { %>
		tb_top.dut.<%=bundle.instancePath%>.dce_func_unit.dm_req_mpf2
              <%} else {%>
		tb_top.dut.<%=bundle.strRtlNamePrefix%>.dce_func_unit.dm_req_mpf2
              <% } %>
	<% } %>
            );
        end

        // UPD REQ 
        if (`DCE_DM<%=unitID%>.dm_upd_req_ready_o && `DCE_DM<%=unitID%>.dm_upd_req_valid_i) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h", 
                33,
                $time,
                <%=unitID%>,
                `DCE_DM<%=unitID%>.dm_upd_req_addr_i,
                `DCE_DM<%=unitID%>.dm_upd_req_ns_i,
                `DCE_DM<%=unitID%>.dm_upd_req_iid_i
            );
        end
        // WRITE
        if (`DCE_DM<%=unitID%>.dm_write_ready_o && `DCE_DM<%=unitID%>.dm_write_valid_i) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h", 
                34,
                $time,
                <%=unitID%>,
                `DCE_DM<%=unitID%>.dm_write_addr_i,
                `DCE_DM<%=unitID%>.dm_write_ns_i,
                `DCE_DM<%=unitID%>.dm_write_owner_val_i,
                `DCE_DM<%=unitID%>.dm_write_owner_num_i,
                `DCE_DM<%=unitID%>.dm_write_sharer_vec_i
            );
        end

        // CMD RSP 
        if (`DCE_DM<%=unitID%>.dm_cmd_rsp_ready_i && `DCE_DM<%=unitID%>.dm_cmd_rsp_valid_o) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h", 
                35,
                $time,
                <%=unitID%>,
                $clog2(`DCE_DM<%=unitID%>.dm_cmd_rsp_att_vec_o),
                `DCE_DM<%=unitID%>.dm_cmd_rsp_owner_val_o,
                `DCE_DM<%=unitID%>.dm_cmd_rsp_owner_num_o,
                `DCE_DM<%=unitID%>.dm_cmd_rsp_sharer_vec_o
            );
        end

        // RECALL
        if (`DCE_DM<%=unitID%>.dm_recall_ready_i && `DCE_DM<%=unitID%>.dm_recall_valid_o) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h", 
                36,
                $time,
                <%=unitID%>,
                `DCE_DM<%=unitID%>.dm_cmd_req_addr_i,
                `DCE_DM<%=unitID%>.dm_cmd_req_ns_i,
                `DCE_DM<%=unitID%>.dm_recall_owner_val_o,
                `DCE_DM<%=unitID%>.dm_recall_owner_num_o,
                `DCE_DM<%=unitID%>.dm_recall_sharer_vec_o
            );
        end

        //RETRY
        if (`DCE_DM<%=unitID%>.dm_rtr_ready_i && `DCE_DM<%=unitID%>.dm_rtr_valid_o) begin
           $fdisplay(file_handle, "%0h:%0h:%0h:%0h",
               37,
               $time,
               <%=unitID%>,
               $clog2(`DCE_DM<%=unitID%>.dm_rtr_att_vec_o));
        end

    // SMI interface 
    // TX-NDP port
    <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
        if (`DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_valid && `DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_ready) begin
            <% smi_id = (3 << 24 | 24 << 16 | unitID << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                24,
                $time,
                <%=unitID%>,
                `DCE<%=unitID%>.smi_tx<%=i%>_ndp_ndp_len,
                `DCE<%=unitID%>.smi_tx<%=i%>_ndp_targ_id,
                `DCE<%=unitID%>.smi_tx<%=i%>_ndp_src_id,
                `DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_id,
                `DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `DCE<%=unitID%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `DCE<%=unitID%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `DCE<%=unitID%>.smi_tx<%=i%>_ndp_ndp,
                `DCE<%=unitID%>.smi_tx<%=i%>_ndp_dp_present,
                <%=smi_id%>
            );
        end
    <% } %>
    // RX-NDP port
    <% for (var i = 0; i < bundle.smiPortParams.rx.length; i++) { %>
        if (`DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_valid && `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_ready) begin
            <% smi_id = (3 << 24 | 25 << 16 | unitID << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                25,
                $time,
                <%=unitID%>,
                `DCE<%=unitID%>.smi_rx<%=i%>_ndp_ndp_len,
                `DCE<%=unitID%>.smi_rx<%=i%>_ndp_targ_id,
                `DCE<%=unitID%>.smi_rx<%=i%>_ndp_src_id,
                `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_id,
                `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `DCE<%=unitID%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `DCE<%=unitID%>.smi_rx<%=i%>_ndp_ndp, 
                `DCE<%=unitID%>.smi_rx<%=i%>_ndp_dp_present,
                <%=smi_id%>
            );
        end // if (`DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_valid && `DCE<%=unitID%>.smi_rx<%=i%>_ndp_msg_ready)
                                                                  
    <% } %>
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>
    end // always @ (negedge `DCE<%=unitID%>.<%=bundle.interfaces.clkInt.name%>clk)
    `undef DCE_DM<%=unitID%>
    `undef DCE<%=unitID%>
<% }); %>

// --------------------------------------------------
// DCE UNIT END
// --------------------------------------------------}

// {--------------------------------------------------
// DVE UNIT START
// --------------------------------------------------
<% obj.DveInfo.forEach(function(bundle, indx) { %>
<% unitID = obj.AiuInfo.length + obj.DceInfo.length + indx; %>

<% }); %>
// DVE UNIT END 
// --------------------------------------------------}

// {--------------------------------------------------
// DMI UNIT START
// --------------------------------------------------
<% obj.DmiInfo.forEach(function(bundle, indx) { %>
<% unitID = obj.AiuInfo.length + obj.DceInfo.length + obj.DveInfo.length + indx; %>


<% if (bundle.useCmc === 1) { %> 
    // CCP signals
    <% if(obj.testBench == "emu") { %>
       `define DMI_CCP<%=indx%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp
       always @(posedge `DMI_CCP<%=indx%>.clk) begin
          if (clk_en) begin
    <% } else { %>
        <% if(bundle.hierPath && bundle.hierPath !== ''){ %>
           `define DMI_CCP<%=indx%> tb_top.dut.<%=bundle.instancePath%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp
        <%} else {%>
           `define DMI_CCP<%=indx%> tb_top.dut.<%=bundle.strRtlNamePrefix%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp
        <% } %>
    always @(negedge `DMI_CCP<%=indx%>.clk) begin
	<% } %>
        // Lookup request
        if (`DMI_CCP<%=indx%>.ctrl_op_valid_p0 && `DMI_CCP<%=indx%>.cache_op_ready_p0) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h",
                64,
                $time,
                <%=unitID%>,
                `DMI_CCP<%=indx%>.ctrl_op_address_p0,
                `DMI_CCP<%=indx%>.ctrl_op_security_p0
            );
        end

        // Lookup response
        if (`DMI_CCP<%=indx%>.cache_valid_p2) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h",
                65,
                $time,
                <%=unitID%>,
                `DMI_CCP<%=indx%>.cache_current_state_p2,
                `DMI_CCP<%=indx%>.ctrl_op_state_p2, 
                {   `DMI_CCP<%=indx%>.ctrl_op_write_data_p2, `DMI_CCP<%=indx%>.ctrl_op_read_data_p2, 
                    `DMI_CCP<%=indx%>.ctrl_op_allocate_p2,   `DMI_CCP<%=indx%>.cache_nack_no_allocate_p2,
                    `DMI_CCP<%=indx%>.cache_nack_ce_p2,      `DMI_CCP<%=indx%>.cache_nack_uce_p2,
                    `DMI_CCP<%=indx%>.cache_nack_p2
                }
            );
        end

        // Evict
        if (`DMI_CCP<%=indx%>.cache_evict_valid_p2) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h",
                66,
                $time,
                <%=unitID%>,
                `DMI_CCP<%=indx%>.cache_evict_address_p2,
                `DMI_CCP<%=indx%>.cache_evict_security_p2, 
                `DMI_CCP<%=indx%>.cache_evict_state_p2
            );
        end
        <% if (bundle.ccpParams.useScratchPad === 1) { %> 
            // ScratchPad Signals
            <% if(obj.testBench == "emu") { %>
                `define DMI_SP<%=indx%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp
                always @(posedge `DMI_SP<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
	    <% } else { %>
                 <% if(bundle.hierPath && bundle.hierPath !== ''){ %>
                      `define DMI_SP<%=indx%> tb_top.dut.<%=bundle.instancePath%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp
                 <%} else {%>
                      `define DMI_SP<%=indx%> tb_top.dut.<%=bundle.strRtlNamePrefix%>.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp
                 <% } %>
                always @(negedge `DMI_SP<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
            <% } %>
                // SP request 
                if (`DMI_SP<%=indx%>.scratch_op_ready & `DMI_SP<%=indx%>.scratch_op_valid) begin
                    $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                        67,
                        $time,
                        <%=unitID%>,
                       {   `DMI_SP<%=indx%>.scratch_op_way_num, `DMI_SP<%=indx%>.scratch_op_index_addr,
                           `DMI_SP<%=indx%>.scratch_op_beat_num
                       }, 
                       `DMI_SP<%=indx%>.scratch_op_read_data,
                       `DMI_SP<%=indx%>.scratch_op_write_data,
                       `DMI_SP<%=indx%>.scratch_op_burst_len,
                       `DMI_SP<%=indx%>.scratch_op_burst_wrap
                    );
                end
                // SP write data 
                //if (`DMI_SP<%=indx%>.scratch_wr_valid && `DMI_SP<%=indx%>.scratch_wr_ready) begin
                //    $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                //        68, $time, <%=unitID%>, `DMI_SP<%=indx%>.scratch_wr_data,
                //        `DMI_SP<%=indx%>.scratch_wr_byte_en, `DMI_SP<%=indx%>.scratch_wr_beat_num,
                //        `DMI_SP<%=indx%>.scratch_wr_last);
                //end
                //// SP read data
                //if (`DMI_SP<%=indx%>.scratch_rdrsp_valid && `DMI_SP<%=indx%>.scratch_rdrsp_ready) begin
                //    $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                //        69, $time, <%=unitID%>, `DMI_SP<%=indx%>.scratch_rdrsp_data,
                //        `DMI_SP<%=indx%>.scratch_rdrsp_byteen, `DMI_SP<%=indx%>.scratch_rdrsp_cancel,
                //        `DMI_SP<%=indx%>.scratch_rdrsp_last);
                //end
            end
        <% } %>
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>
      end // always @ (negedge `DMI_CCP<%=indx%>.clk)
      `undef DMI_CCP<%=indx%>
    <% } %>

    <% if(obj.testBench == "emu") { %>
        `define DMI<%=indx%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>
        always @(posedge `DMI<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
            if (clk_en) begin
    <% } else { %>
        <% if(bundle.hierPath && bundle.hierPath !== ''){ %>
           `define DMI<%=indx%> tb_top.dut.<%=bundle.instancePath%>
        <%}else{%>
           `define DMI<%=indx%> tb_top.dut.<%=bundle.strRtlNamePrefix%>
        <%}%>
        always @(negedge `DMI<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
    <% } %>
        // AXI interface
        // ar channel
        // zero for domain, snoop, bar
        if (`DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_valid && `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                12,
                $time,
                <%=unitID%>,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_id,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_addr,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_len,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_size,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_burst,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_lock,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_cache,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_prot,
                <% if (bundle.interfaces.axiInt.params.wQos > 0) { %> `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_qos <% } else { %> 0 <% } %>,
                0,
                <% if (bundle.interfaces.axiInt.params.wArUser > 0) { %> `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_user <% } else { %> 0 <% } %>,
                0,
                0, // `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_xsnoop,
                0
            );
        end

        // aw channel
        // zero for domain, snoop, bar, unique
        if (`DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_valid && `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                13,
                $time,
                <%=unitID%>,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_id,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_addr,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_len,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_size,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_burst,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_lock,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_cache,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_prot,
                <% if (bundle.interfaces.axiInt.params.wQos > 0) { %> `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_qos <% } else { %> 0 <% } %>,
                0,
                <% if (bundle.interfaces.axiInt.params.wAwUser > 0) { %> `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_user <% } else { %> 0 <% } %>,
                0,
                0, // `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_xsnoop,
                0,
                0
            );
        end

        // w channel
        // zero for wuser
        if (`DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_valid && `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                14,
                $time,
                <%=unitID%>,
                0,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_data,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_strb,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_last,
            );
        end

        // b channel
        // zero for buser
        if (`DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_valid && `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h",
                15,
                $time,
                <%=unitID%>,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_id,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_resp,
                0
            );
        end

        // r channel
        // zero for ruser
        if (`DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_valid && `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                16,
                $time,
                <%=unitID%>,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_id,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_resp,
                0,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_data,
                `DMI<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_last
            );
        end
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>
    end // always @ (negedge `DMI<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk)

    <% if(obj.testBench == "emu") { %>
    always @(posedge `DMI<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
		if (clk_en) begin
	<% } else { %>
    always @(negedge `DMI<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
	<% } %>
    // SMI interface 
    <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
    <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
         // TX-DP port
         if (`DMI<%=indx%>.smi_tx<%=i%>_dp_valid && `DMI<%=indx%>.smi_tx<%=i%>_dp_ready) begin 
            <% smi_id = (4 << 24 | 26 << 16 | indx << 8 | i ); %>       
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                26,
                $time,
                <%=unitID%>,
                `DMI<%=indx%>.smi_tx<%=i%>_dp_data, 
                `DMI<%=indx%>.smi_tx<%=i%>_dp_user,
                `DMI<%=indx%>.smi_tx<%=i%>_dp_last,
                <%=smi_id%>
            );
         end
    <% } %>
         // TX-NDP port
         if (`DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_valid && `DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_ready) begin
            <% smi_id = (4 << 24 | 24 << 16 | indx << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                24,
                $time,
                <%=unitID%>,
                `DMI<%=indx%>.smi_tx<%=i%>_ndp_ndp_len,
                `DMI<%=indx%>.smi_tx<%=i%>_ndp_targ_id,
                `DMI<%=indx%>.smi_tx<%=i%>_ndp_src_id,
                `DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_id,
                `DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `DMI<%=indx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `DMI<%=indx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `DMI<%=indx%>.smi_tx<%=i%>_ndp_ndp,
                `DMI<%=indx%>.smi_tx<%=i%>_ndp_dp_present,
                <%=smi_id%>);
         end
    <% } %> 
						
    <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
    <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>
         // RX-DP port
         if (`DMI<%=indx%>.smi_rx<%=i%>_dp_valid && `DMI<%=indx%>.smi_rx<%=i%>_dp_ready) begin
            <% smi_id = (4 << 24 | 27 << 16 | indx << 8 | i ); %>        
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                27,
                $time,
                <%=unitID%>,
                `DMI<%=indx%>.smi_rx<%=i%>_dp_data, 
                `DMI<%=indx%>.smi_rx<%=i%>_dp_user,
                `DMI<%=indx%>.smi_rx<%=i%>_dp_last,
                <%=smi_id%>
            );
         end
    <% } %>
         // RX-NDP port
         if (`DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_valid && `DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_ready) begin
           <% smi_id = (4 << 24 | 25 << 16 | indx << 8 | i ); %>
           $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
               25,
               $time,
               <%=unitID%>,
               `DMI<%=indx%>.smi_rx<%=i%>_ndp_ndp_len,
               `DMI<%=indx%>.smi_rx<%=i%>_ndp_targ_id,
               `DMI<%=indx%>.smi_rx<%=i%>_ndp_src_id,
               `DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_id,
               `DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_type, 
               <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
               <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
               <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `DMI<%=indx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
               <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
               <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `DMI<%=indx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
               `DMI<%=indx%>.smi_rx<%=i%>_ndp_ndp,
               `DMI<%=indx%>.smi_rx<%=i%>_ndp_dp_present,
               <%=smi_id%>);
         end
    <% } %> 
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>
    end // always @ (negedge `DMI<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk)
    `undef DMI<%=indx%>
<% }); %>

// --------------------------------------------------
// DMI UNIT END 
// --------------------------------------------------}

// {--------------------------------------------------
// DII UNIT START
// --------------------------------------------------
<% obj.DiiInfo.forEach(function(bundle, indx) { %>
<% unitID = obj.AiuInfo.length + obj.DceInfo.length + obj.DveInfo.length + obj.DmiInfo.length + indx; %>
<% if (bundle.fnNativeInterface === "AXI4") { %>
    <% if(obj.testBench == "emu") { %>
 //   `define DII<%=indx%> ncore_hdl_top.dut.u_dii_<%=indx%>
    `define DII<%=indx%> ncore_hdl_top.dut.<%=bundle.strRtlNamePrefix%>
    always @(posedge `DII<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
		if (clk_en) begin
	<% } else { %>
 //   `define DII<%=indx%> tb_top.dut.u_dii_<%=indx%>
<% if (bundle.hierPath && bundle.hierPath!=='') {%>
    `define DII<%=indx%> tb_top.dut.<%=bundle.instancePath%>
<%}else{%>
    `define DII<%=indx%> tb_top.dut.<%=bundle.strRtlNamePrefix%>
<% } %>
    always @(negedge `DII<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk) begin
	<% } %>
        // AXI interface
        // ar channel
        // zero for domain, snoop, bar
        if (`DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_valid && `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                12,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_id,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_addr,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_len,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_size,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_burst,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_lock,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_cache,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_prot,
                <% if (bundle.interfaces.axiInt.params.wQos > 0) { %> `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_qos <% } else { %> 0 <% } %>,
                0,
<%     if (bundle.interfaces.axiInt.params.wArUser > 0) { %>
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>ar_user,
<%   }   else  { %> 0,  
<%   }   %>
                0,
                0,
                0
            );
        end
        // aw channel
        // zero for domain, snoop, bar, unique
        if (`DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_valid && `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                13,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_id,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_addr,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_len,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_size,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_burst,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_lock,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_cache,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_prot,
                <% if (bundle.interfaces.axiInt.params.wQos > 0) { %> `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_qos <% } else { %> 0 <% } %>,
                0,
<%     if (bundle.interfaces.axiInt.params.wAwUser > 0) { %>
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>aw_user,
<%   }   else  { %> 0,  
<%  }  %>
                0,
                0,
                0,
                0 
            );
        end
        // w channel
        if (`DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_valid && `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                14,
                $time,
                <%=unitID%>,
<%     if (bundle.interfaces.axiInt.params.wWUser > 0) { %>
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_user,
<%   }   else  { %> 0,  
<%   }   %>
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_data,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_strb,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>w_last
            );
        end
        // b channel
        if (`DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_valid && `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h",
                15,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_id,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_resp,
<%     if (bundle.interfaces.axiInt.params.wBUser > 0) { %>
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>b_user,
<%   }   else  { %> 0  
<%   }   %>
            );
        end
        // r channel
        if (`DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_valid && `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_ready) begin
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                16,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_id,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_resp,
<%     if (bundle.interfaces.axiInt.params.wRUser > 0) { %>
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_user,
<%   }   else  { %> 0,  
<%   }   %>
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_data,
                `DII<%=indx%>.<%=bundle.interfaces.axiInt.name%>r_last
            );
        end     
<% } %>

    // SMI interface 
    <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
    <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
         // TX-DP port
         if (`DII<%=indx%>.smi_tx<%=i%>_dp_valid && `DII<%=indx%>.smi_tx<%=i%>_dp_ready) begin
            <% smi_id = (5 << 24 | 26 << 16 | indx << 8 | i ); %>        
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                26,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.smi_tx<%=i%>_dp_data, 
                `DII<%=indx%>.smi_tx<%=i%>_dp_user,
                `DII<%=indx%>.smi_tx<%=i%>_dp_last,
                <%=smi_id%>
            );
         end
    <% } %>
         // TX-NDP port
         if (`DII<%=indx%>.smi_tx<%=i%>_ndp_msg_valid && `DII<%=indx%>.smi_tx<%=i%>_ndp_msg_ready) begin
            <% smi_id = (5 << 24 | 24 << 16 | indx << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                24,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.smi_tx<%=i%>_ndp_ndp_len,
                `DII<%=indx%>.smi_tx<%=i%>_ndp_targ_id,
                `DII<%=indx%>.smi_tx<%=i%>_ndp_src_id,
                `DII<%=indx%>.smi_tx<%=i%>_ndp_msg_id,
                `DII<%=indx%>.smi_tx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiuser  > 0) { %> `DII<%=indx%>.smi_tx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiTier  > 0) { %> `DII<%=indx%>.smi_tx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiSteer > 0) { %> `DII<%=indx%>.smi_tx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiPri   > 0) { %> `DII<%=indx%>.smi_tx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiTxInt[i].params.wSmiQos   > 0) { %> `DII<%=indx%>.smi_tx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `DII<%=indx%>.smi_tx<%=i%>_ndp_ndp,
                `DII<%=indx%>.smi_tx<%=i%>_ndp_dp_present,
                <%=smi_id%>
            );
         end
    <% } %> 

    <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
    <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>					       
         // RX-DP port
         if (`DII<%=indx%>.smi_rx<%=i%>_dp_valid && `DII<%=indx%>.smi_rx<%=i%>_dp_ready) begin
            <% smi_id = (5 << 24 | 27 << 16 | indx << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                27,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.smi_rx<%=i%>_dp_data, 
                `DII<%=indx%>.smi_rx<%=i%>_dp_user,
                `DII<%=indx%>.smi_rx<%=i%>_dp_last,
                <%=smi_id%>
            );
         end
    <% } %>
         // RX-NDP port
         if (`DII<%=indx%>.smi_rx<%=i%>_ndp_msg_valid && `DII<%=indx%>.smi_rx<%=i%>_ndp_msg_ready) begin
            <% smi_id = (5 << 24 | 25 << 16 | indx << 8 | i ); %>
            $fdisplay(file_handle, "%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h:%0h",
                25,
                $time,
                <%=unitID%>,
                `DII<%=indx%>.smi_rx<%=i%>_ndp_ndp_len,
                `DII<%=indx%>.smi_rx<%=i%>_ndp_targ_id,
                `DII<%=indx%>.smi_rx<%=i%>_ndp_src_id,
                `DII<%=indx%>.smi_rx<%=i%>_ndp_msg_id,
                `DII<%=indx%>.smi_rx<%=i%>_ndp_msg_type, 
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiuser  > 0) { %> `DII<%=indx%>.smi_rx<%=i%>_ndp_msg_user <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiTier  > 0) { %> `DII<%=indx%>.smi_rx<%=i%>_ndp_msg_tier <% } else { %> 0 <% } %>, 
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiSteer > 0) { %> `DII<%=indx%>.smi_rx<%=i%>_ndp_steer    <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiPri   > 0) { %> `DII<%=indx%>.smi_rx<%=i%>_ndp_msg_pri  <% } else { %> 0 <% } %>,
                <% if (bundle.interfaces.smiRxInt[i].params.wSmiQos   > 0) { %> `DII<%=indx%>.smi_rx<%=i%>_ndp_msg_qos  <% } else { %> 0 <% } %>,
                `DII<%=indx%>.smi_rx<%=i%>_ndp_ndp,
                `DII<%=indx%>.smi_rx<%=i%>_ndp_dp_present,
                <%=smi_id%>
            );
         end
    <% } %> 
	<% if(obj.testBench == "emu") { %>
	end
	<% } %>
    end // always @ (negedge `DII<%=indx%>.<%=bundle.interfaces.clkInt.name%>clk)
    `undef DII<%=indx%>
<% }); %>

// --------------------------------------------------
// DII UNIT END
// --------------------------------------------------}

<% if(obj.testBench=="emu") { %>
    // Unit ID calculation
    <% var ncidx = 0; %>
    <% var ncidx_rx = 0; %>
    // tbx vif_binding_block
    initial begin
        import uvm_pkg::uvm_config_db;
    <% obj.AiuInfo.forEach(function(bundle, indx) { %>
        <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
            <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
                uvm_config_db #(virtual ioaiu_smi_bfm_<%=ncidx%>)::set(null, "uvm_test_top", "ioaiu_smi_bfm_<%=ncidx%>" , ioaiu_smi_bfm_<%=ncidx%>);
                <% ncidx++; %>
    		<% } %>
            uvm_config_db #(virtual ioaiu_smi_bfm_<%=ncidx%>)::set(null, "uvm_test_top", "ioaiu_smi_bfm_<%=ncidx%>" , ioaiu_smi_bfm_<%=ncidx%>);
            <% ncidx++; %>
        <% } %>
        <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>
                uvm_config_db #(virtual ioaiu_smi_bfm_rx_<%=ncidx_rx%>)::set(null, "uvm_test_top", "ioaiu_smi_bfm_rx_<%=ncidx_rx%>" , ioaiu_smi_bfm_rx_<%=ncidx_rx%>);
                <% ncidx_rx++; %>
    		<% } %>
            uvm_config_db #(virtual ioaiu_smi_bfm_rx_<%=ncidx_rx%>)::set(null, "uvm_test_top", "ioaiu_smi_bfm_rx_<%=ncidx_rx%>" , ioaiu_smi_bfm_rx_<%=ncidx_rx%>);
            <% ncidx_rx++; %>
        <% } %>
    <% }); %>
end
<% } %>

endmodule: ncore_probe_module
