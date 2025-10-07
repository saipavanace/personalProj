parameter int WQOS          = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wQos%>;
parameter int TAGOP         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp ? obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp : 0 %>;
parameter int WTGID         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.TgtID%>;
parameter int WSRCID        = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.SrcID%>;
parameter int WTXNID        = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID%>;
parameter int WREQOPCODE    = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_Opcode%>;
parameter int WSIZE         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.Size%>;
parameter int WADDR         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wAddr%>;
parameter int WORDER        = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.Order%>;
parameter int WMEMATTR      = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.MemAttr%>;
parameter int WSNPATTR      = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.SnpAttr%>;
parameter int WLPID         = <%if(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-E"){%>8<%} else {%><%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.LPID%><%}%>;
<% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) { %>
parameter int WREQRSVDC     = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC%>;
<% } else { %>
parameter int WREQRSVDC     = 0;
<% } %>
<% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.DATA_RSVDC) { %>
parameter int WDATRSVDC     = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DATA_RSVDC%>;
<% } else { %>
parameter int WDATRSVDC     = 0;
<% } %>
parameter int WSNPOPCODE    = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.SNP_Opcode%>;
parameter int WDATAOPCODE   = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DAT_Opcode%>;
parameter int WRESPERR      = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.RespErr%>;
parameter int WRESP         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.Resp%>;
parameter int WCCID         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.CCID%>;
parameter int WDATASOURCE   = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataSource ? obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataSource : 0 %>;
parameter int WCBUSY        = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.CBusy ? obj.AiuInfo[obj.Id].interfaces.chiInt.params.CBusy : 0 %>;
parameter int WDATATAGOP    = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp ? obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp : 0%>;
parameter int WDATAID       = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DataID%>;
parameter int WDATA         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData%>;
parameter int WBE           = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.BE%>;
parameter int WDATACHECK    = WDATA / 8;
parameter int WPOSION       = WDATA / 64;
parameter int WTAG          = WDATA / 32;
parameter int WTU           = WDATA / 128;
parameter int WRSPOPCODE    = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.RSP_Opcode%>;
parameter int WDBID         = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.DBID%>;
parameter int WPCRDTYPE     = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.PCrdType%>;
parameter int WRETURNNID    = WTGID;
parameter int WRETURNTXNIND = WTXNID;
parameter int WSTASHNID     = WSRCID;
parameter int WHOMENID      = WSRCID;
parameter int WFWDSTATE     = 3;
parameter int WDATAPULL     = 3;
parameter int WFWDNID       = WSRCID;
parameter int WFWDTXNID     = WTXNID;
parameter int WVMIDEXT      = WTXNID;
parameter int WSNPADDR      = WADDR - 3;
parameter int WSLCREPHINT   = 7;
parameter int WPGROUPID     = 8;
parameter int WSTASHGROUPID = WPGROUPID;
parameter int WTAGGROUPID   = WPGROUPID;

parameter int WTAGOP        = <%if(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-E"){%> <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.TagOp%><%} else {%> 0<%}%>;
parameter int WMPAM         = 0; // <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.MPAM%>; // Not supported


//Interface Parameters
parameter int WREQFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wReqflit%>;
parameter int WDATFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wDatflit%>;
parameter int WRSPFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wRspflit%>;
parameter int WSNPFLIT = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.wSnpflit%>;
parameter int MAX_FW   = WDATFLIT;

