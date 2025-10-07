parameter int SVT_CHI_NODE_WQOS          = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wQos%>;
parameter int SVT_CHI_NODE_WTGID         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.TgtID%>;
parameter int SVT_CHI_NODE_WSRCID        = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.SrcID%>;
parameter int SVT_CHI_NODE_WTXNID        = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID%>;
parameter int SVT_CHI_NODE_WREQOPCODE    = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_Opcode%>;
parameter int SVT_CHI_NODE_WSIZE         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.Size%>;
parameter int SVT_CHI_NODE_WADDR         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wAddr%>;
parameter int SVT_CHI_NODE_WORDER        = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.Order%>;
parameter int SVT_CHI_NODE_WMEMATTR      = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.MemAttr%>;
parameter int SVT_CHI_NODE_WSNPATTR      = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.SnpAttr%>;
parameter int SVT_CHI_NODE_WLPID         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.LPID%>;
<% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) { %>
parameter int SVT_CHI_NODE_WREQRSVDC     = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC%>;
<% } else { %>
parameter int SVT_CHI_NODE_WREQRSVDC     = 0;
<% } %>
<% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.DATA_RSVDC) { %>
parameter int SVT_CHI_NODE_WDATRSVDC     = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DATA_RSVDC%>;
<% } else { %>
parameter int SVT_CHI_NODE_WDATRSVDC     = 0;
<% } %>
parameter int SVT_CHI_NODE_WSNPOPCODE    = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.SNP_Opcode%>;
parameter int SVT_CHI_NODE_WDATAOPCODE   = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DAT_Opcode%>;
parameter int SVT_CHI_NODE_WRESPERR      = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.RespErr%>;
parameter int SVT_CHI_NODE_WRESP         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.Resp%>;
parameter int SVT_CHI_NODE_WCCID         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.CCID%>;
parameter int SVT_CHI_NODE_WDATAID       = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataID%>;
parameter int SVT_CHI_NODE_WDATA         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData%>;
parameter int SVT_CHI_NODE_WBE           = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.BE%>;
parameter int SVT_CHI_NODE_WDATACHECK    = SVT_CHI_NODE_WDATA / 8;
parameter int SVT_CHI_NODE_WPOSION       = SVT_CHI_NODE_WDATA / 64;
parameter int SVT_CHI_NODE_WRSPOPCODE    = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.RSP_Opcode%>;
parameter int SVT_CHI_NODE_WDBID         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DBID%>;
parameter int SVT_CHI_NODE_WPCRDTYPE     = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.PCrdType%>;
parameter int SVT_CHI_NODE_WRETURNNID    = SVT_CHI_NODE_WTGID;
parameter int SVT_CHI_NODE_WRETURNTXNIND = SVT_CHI_NODE_WTXNID;
parameter int SVT_CHI_NODE_WSTASHNID     = SVT_CHI_NODE_WSRCID;
parameter int SVT_CHI_NODE_WHOMENID      = SVT_CHI_NODE_WSRCID;
parameter int SVT_CHI_NODE_WFWDSTATE     = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.FwdState%>;
parameter int SVT_CHI_NODE_WDATAPULL     = 3;
parameter int SVT_CHI_NODE_WDATASOURCE   = <%=(obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataSource)?obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataSource : obj.AiuInfo[obj.Id].interfaces.chiInt.params.FwdState%>;
parameter int SVT_CHI_NODE_WFWDNID       = SVT_CHI_NODE_WSRCID;
parameter int SVT_CHI_NODE_WFWDTXNID     = SVT_CHI_NODE_WTXNID;
parameter int SVT_CHI_NODE_WVMIDEXT      = SVT_CHI_NODE_WTXNID;
parameter int SVT_CHI_NODE_WSNPADDR      = SVT_CHI_NODE_WADDR - 3;


//Interface Parameters
parameter int SVT_CHI_NODE_WREQFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wReqflit%>;
parameter int SVT_CHI_NODE_WDATFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wDatflit%>;
parameter int SVT_CHI_NODE_WRSPFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wRspflit%>;
parameter int SVT_CHI_NODE_WSNPFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wSnpflit%>;
parameter int SVT_CHI_NODE_MAX_FW   = SVT_CHI_NODE_WDATFLIT;

