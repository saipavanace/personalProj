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
<% if (obj.testBench == "emu" ) { %>
interface <%=obj.BlockId%>_chi_emu_if (input logic clk, reset_n);
    
    import <%=obj.BlockId%>_chi_agent_pkg::*;
    `include "vtl_chi_types.svh"
    bit [ WREQRSVDC-1   : 0 ]  req_rsvdc;       
    bit req_tracetag;    
    bit req_expcompack;  
    bit req_excl;        
    bit [ WLPID-1         : 0 ] req_lpid;      
    bit [ WSNPATTR-1      : 0 ] req_snpattr  ;   
    bit [ WMEMATTR-1      : 0 ] req_memattr ;    
    bit [ WPCRDTYPE-1     : 0 ] req_pcrdtype ;   
    bit [ WORDER-1        : 0 ] req_order  ;     
    bit req_allowretry ; 
    bit req_likelyshared;
    bit req_ns;	  
    bit [(WADDR - 1) 	: 0] req_addr ;       
    bit [ WSIZE-1           : 0] req_size ;       
    bit [ WREQOPCODE-1      : 0] req_opcode ;     
    bit [ WTXNID-1          : 0]  req_txnid ;      
    bit [ WTGID-1           : 0] req_tgtid ;      
    bit [ WQOS-1            : 0] req_qos ;       
    
    bit [ WDATRSVDC - 1 : 0 ] data_rsvdc;   
    bit [ WDATA-1         : 0 ] data_data;    
    bit [ WBE-1           : 0 ] data_be;      
    bit data_tracetag;
    bit [ WCCID-1         : 0 ] data_ccid;    
    bit [ WDATAID-1       : 0 ] data_dataid ; 
    bit [ WDBID-1         : 0 ] data_dbid;    
    bit [ WORDER-1        : 0 ] data_order ;  
    bit [ WDATAPULL - 1   : 0 ] data_datapull;
    bit [ WRESP-1         : 0 ] data_resp;    
    bit [ WRESPERR-1      : 0 ] data_resperr; 
    bit [ WHOMENID -1     : 0 ] data_homenid ;
    bit [ WDATAOPCODE-1   : 0 ] data_opcode ;
    bit [ WTXNID-1        : 0 ] data_txnid ;  
    bit [ WSRCID-1        : 0 ] data_tgtid ;  
    bit [ WQOS-1          : 0 ] data_qos;     
    bit [ WDATA-1         : 0 ] chi_rdata;
    
    
    chi_req_seq_item  pkt_req[$];
    

task chk_wr_data();
   $display($time,"INTERFACE_WRITE : addr is %h data is %h req_qos is %h dat_qos %h",req_addr,data_data,req_qos,data_qos); 


    if (req_opcode == CHI_WRITE_NO_SNP_PTL) begin
    
    chi_req_wrdat_chk(.req_rsvdc(req_rsvdc),.req_tracetag(req_tracetag),.cmd(req_opcode),.addr(req_addr),.Size(req_size),.ExCompAck(req_expcompack),.Excl(req_excl),.LPID(req_lpid),.SnpAttr(req_snpattr),.MemAttr(req_memattr),.PCrdType(req_pcrdtype),.Order(req_order),.Retry(req_allowretry),.LikelyShared(req_likelyshared),.NS(req_ns),.ReturnTxnID(0),.StashNIDValid(0),.ReturnNID(0),.TxnID(req_txnid),.SrcID(0),.TgtID(req_tgtid),.QoS(req_qos),.timestamp(106375),.ByteEnb(data_be),.data(data_data),.nb(1'b0), .dat_rsvdc(data_rsvdc), .dat_tracetag(data_tracetag), .dat_dataid(data_dataid), .dat_dbid(data_dbid), .dat_datapull(data_datapull), .dat_resp(data_resp), .dat_resperr(data_resperr), .dat_opcode(data_opcode), .dat_homenid(data_homenid), .dat_txnid(data_txnid), .dat_tgtid(data_tgtid), .dat_qos(data_qos));
    
    end else begin
    
    chi_req_wrdat_chk_diff(.req_rsvdc(req_rsvdc),.req_tracetag(req_tracetag),.cmd(req_opcode),.addr(req_addr),.Size(req_size),.ExCompAck(req_expcompack),.Excl(req_excl),.LPID(req_lpid),.SnpAttr(req_snpattr),.MemAttr(req_memattr),.PCrdType(req_pcrdtype),.Order(req_order),.Retry(req_allowretry),.LikelyShared(req_likelyshared),.NS(req_ns),.ReturnTxnID(0),.StashNIDValid(0),.ReturnNID(0),.TxnID(req_txnid),.SrcID(0),.TgtID(req_tgtid),.QoS(req_qos),.timestamp(106375),.ByteEnb(data_be),.data(data_data),.nb(1'b0), .dat_rsvdc(data_rsvdc), .dat_tracetag(data_tracetag), .dat_dataid(data_dataid), .dat_dbid(data_dbid), .dat_datapull(data_datapull), .dat_resp(data_resp), .dat_resperr(data_resperr), .dat_opcode(data_opcode), .dat_homenid(data_homenid), .dat_txnid(data_txnid), .dat_tgtid(data_tgtid), .dat_qos(data_qos));
    
    end

endtask :chk_wr_data 

task chk_rd_data();
bit [9:0] read_count ;
chi_req_rdat_chk(.req_rsvdc(req_rsvdc),.req_tracetag(req_tracetag),.cmd(req_opcode),.addr(req_addr),.Size(req_size),.ExCompAck(req_expcompack),.Excl(req_excl),.LPID(req_lpid),.SnpAttr(req_snpattr),.MemAttr(req_memattr),.PCrdType(req_pcrdtype),.Order(req_order),.Retry(req_allowretry),.LikelyShared(req_likelyshared),.NS(req_ns),.ReturnTxnID(0),.StashNIDValid(0),.ReturnNID(0),.TxnID(req_txnid),.SrcID(0),.TgtID(req_tgtid),.QoS(req_qos),.timestamp(106375),.ByteEnb(data_be),.data(data_data),.nb(1'b0), .dat_rsvdc(data_rsvdc), .dat_tracetag(data_tracetag), .dat_dataid(data_dataid), .dat_dbid(data_dbid), .dat_datapull(data_datapull), .dat_resp(data_resp), .dat_resperr(data_resperr), .dat_opcode(data_opcode), .dat_homenid(data_homenid), .dat_txnid(data_txnid), .dat_tgtid(data_tgtid), .dat_qos(data_qos), .rdata(chi_rdata));


   $display($time,"INTERFACE_READ : addr is %h data is %h req_qos is %h dat_qos %h",req_addr,chi_rdata,req_qos,data_qos); 
endtask :chk_rd_data
//##########################################################################################################################################
task chi_req_wrdat_chk(
    integer 		timestamp,
    bit			nb,
    bit [(WDATA - 1)	: 0]	data,
    bit [(WDATA/8 - 1)	: 0]	ByteEnb,
    bit [5:0] 		cmd,
    input bit [(WADDR - 1) 	: 0] 	addr,
    bit [2:0] 		Size,
    bit 			ExCompAck,
    bit 			Excl,  	
    bit [4:0] 		LPID,
    bit [1:0] 		SnpAttr,
    bit [3:0]               MemAttr,
    bit [1:0] 		PCrdType,
    bit [1:0] 		Order,	
    bit 			Retry,
    bit 			LikelyShared,
    bit [1:0] 		NS,
    bit [2:0] 		ReturnTxnID,
    bit 			StashNIDValid,
    bit 			ReturnNID, 
    bit [7:0] 		TxnID,
    bit [(WSRCID - 1) 	: 0]  	SrcID,
    bit [(WSRCID - 1) 	: 0]  	TgtID,
    bit [3:0] 		QoS,
    bit [3:0] req_rsvdc,
    bit req_tracetag,
      
    bit [3:0] dat_rsvdc,
    bit dat_tracetag,
    bit [2:0] dat_dataid,
    //bit [(CHI_TXN_ID_WIDTH - 1) : 0]dat_dbid,
    bit [(WTXNID - 1) : 0]dat_dbid,
    bit [2:0] dat_datapull,
    bit [2:0] dat_resp,
    bit [(512/WDATA - 1) : 0] dat_resperr,
    bit [3:0] dat_opcode,
    bit [(WSRCID - 1) :0] dat_homenid,
    bit [7:0] dat_txnid,
    bit [(WSRCID- 1) : 0] dat_tgtid,
    bit [3:0] dat_qos
);

    automatic vtl_chi_req_pkt_s req_pkt_s;
    automatic vtl_chi_rsp_pkt_s primary_rsp_pkt_s ;
    automatic vtl_chi_rsp_pkt_s secondary_rsp_pkt_s ;
    automatic vtl_chi_data_pkt_s wr_data_pkt_s ;
    automatic vtl_chi_data_pkt_s rd_data_pkt_s ;

    bit	nb_tmp;

    bit [3:0] chi_id;
    bit [2:0] dataid;
    bit [(WDATA - 1)	: 0]	wdata;
    bit [(WDATA - 1)	: 0]	rdata;   
    wdata = data; // saved write data for checking 

    if (cmd == CHI_WRITE_NO_SNP_FULL) begin
    //cmd = CHI_WRITE_NO_SNP_PTL;
    end


    $cast(req_pkt_s.RSVDC                   , req_rsvdc);
    $cast(req_pkt_s.Trace_Tag               , req_tracetag);
    $cast(req_pkt_s.Exp_Comp_Ack            , ExCompAck);
    $cast(req_pkt_s.Excl_or_Snoop_Me        , Excl);
    $cast(req_pkt_s.LPID                    , LPID);
    $cast(req_pkt_s.Snp_Attr                , SnpAttr);
    $cast(req_pkt_s.Mem_Attr	            , MemAttr);
   // $cast(req_pkt_s.Mem_Attr	            , 'h2);
    $cast(req_pkt_s.PCrd_Type               , PCrdType);
    $cast(req_pkt_s.order                   , Order);
    $cast(req_pkt_s.Allow_Retry	            , 1);
    $cast(req_pkt_s.Likely_Shared           , LikelyShared);
    $cast(req_pkt_s.NS		            , NS);
    $cast(req_pkt_s.addr                    , addr);
    $cast(req_pkt_s.size                    , Size);
    $cast(req_pkt_s.opcode                  , cmd);
    $cast(req_pkt_s.TxnID                   , TxnID);
    $cast(req_pkt_s.TgtID                   , TgtID); //ID of the Home Node
    $cast(req_pkt_s.Qos                     ,  QoS);

   wr_data_pkt_s.RSVDC                              = dat_rsvdc ;    
   wr_data_pkt_s.data[addr[5:4]]                    = data;
   wr_data_pkt_s.BE[addr[5:4]]                      = ByteEnb; 
   dataid                                           = {addr[5:4]};
   wr_data_pkt_s.DataID                             = {dataid,dataid+2'b01,dataid+2'b10,dataid+2'b11}; 
   wr_data_pkt_s.Trace_Tag                          = dat_tracetag ;
   wr_data_pkt_s.CCID                               = addr[5:4] ;     
   wr_data_pkt_s.DBID                               = dat_dbid ;     
   wr_data_pkt_s.FwdState_or_DataPull_or_DataSource = dat_datapull ;
   wr_data_pkt_s.Resp                               = dat_resp ;  
   wr_data_pkt_s.Resp_Err                           = dat_resperr ;
   $cast(wr_data_pkt_s.opcode                       , dat_opcode);
   wr_data_pkt_s.HomeNID                            = dat_homenid ; 
   wr_data_pkt_s.TxnID                              = TxnID ;   // This shall be updated in the hardware ...
   wr_data_pkt_s.TgtID                              = dat_tgtid;   
   wr_data_pkt_s.Qos                                = dat_qos;     
   wr_data_pkt_s.valid                              = 1'b1 ;


   rd_data_pkt_s.valid                              = 1'b0 ;
   primary_rsp_pkt_s.valid                          = 1'b0 ;
   secondary_rsp_pkt_s.valid                        = 1'b0 ;

   $display($time, " CHI_EMU_IF : WRITE_TASK data_id is %0h %0h %0h %0h",dataid,dataid+2'h1,dataid+2'h2,dataid+2'h3);
   print_request(req_pkt_s);
   print_data(wr_data_pkt_s);

   mgc_chi_rn_if_0.wait_for_clk (10);
   mgc_chi_rn_if_0.send_txn(req_pkt_s,rd_data_pkt_s,wr_data_pkt_s,primary_rsp_pkt_s,secondary_rsp_pkt_s,0); 
   mgc_chi_rn_if_0.wait_for_clk (10);

    $display($time," CHI_WRITE_TASK : addr is %h data is %h req_qos is %h dat_qos %h data_txnid is %0h data_opcode is %s resp is %0h resp_err is %0h",req_pkt_s.addr,wr_data_pkt_s.data,req_pkt_s.Qos,wr_data_pkt_s.Qos,wr_data_pkt_s.TxnID,wr_data_pkt_s.opcode.name(),wr_data_pkt_s.Resp,wr_data_pkt_s.Resp_Err); 

endtask

//##########################################################################################################################################
task chi_req_rdat_chk(
    integer 		timestamp,
    bit			nb,
    bit [(WDATA - 1)	: 0]	data,
    bit [(WDATA - 1)	: 0]	ByteEnb,
    bit [5:0] 		cmd,
    bit [(WADDR - 1) 	: 0] 	addr,
    bit [2:0] 		Size,
    bit 			ExCompAck,
    bit 			Excl,  	
    bit [4:0] 		LPID,
    bit [1:0] 		SnpAttr,
    bit [3:0]               MemAttr,
    bit [1:0] 		PCrdType,
    bit [1:0] 		Order,	
    bit 			Retry,
    bit 			LikelyShared,
    bit [1:0] 		NS,
    bit [2:0] 		ReturnTxnID,
    bit 			StashNIDValid,
    bit 			ReturnNID, 
    bit [7:0] 		TxnID,
    bit [(WSRCID - 1) 	: 0]  	SrcID,
    bit [(WSRCID - 1) 	: 0]  	TgtID,
    bit [3:0] 		QoS,
    bit [3:0] req_rsvdc,
    bit req_tracetag,
      
    bit [3:0] dat_rsvdc,
    bit dat_tracetag,
    bit [2:0] dat_dataid,
    //bit [(CHI_TXN_ID_WIDTH - 1) : 0]dat_dbid,
    bit [(WTXNID - 1) : 0]dat_dbid,
    bit [2:0] dat_datapull,
    bit [2:0] dat_resp,
    bit [(512/WDATA - 1) : 0] dat_resperr,
    bit [3:0] dat_opcode,
    bit [(WSRCID  - 1) :0] dat_homenid,
    bit [7:0] dat_txnid,
    bit [(WSRCID  - 1) : 0] dat_tgtid,
    bit [3:0] dat_qos,
    output  bit [(WDATA - 1)	: 0]	rdata   
);

    automatic vtl_chi_req_pkt_s req_pkt_s;
    automatic vtl_chi_rsp_pkt_s primary_rsp_pkt_s ;
    automatic vtl_chi_rsp_pkt_s secondary_rsp_pkt_s ;
    automatic vtl_chi_data_pkt_s wr_data_pkt_s ;
    automatic vtl_chi_data_pkt_s rd_data_pkt_s ;

    bit	nb_tmp;
    bit [3:0] chi_id;
    bit [2:0] dataid;
    bit [(WDATA - 1)	: 0]	wdata;
    wdata = data; // saved write data for checking 
    nb_tmp = nb;

    $cast(req_pkt_s.RSVDC                   , req_rsvdc);
    $cast(req_pkt_s.Trace_Tag               , req_tracetag);
    $cast(req_pkt_s.Exp_Comp_Ack            , ExCompAck);
    $cast(req_pkt_s.Excl_or_Snoop_Me        , Excl);
    $cast(req_pkt_s.LPID                    , LPID);
    $cast(req_pkt_s.Snp_Attr                , SnpAttr);
    $cast(req_pkt_s.Mem_Attr	            , MemAttr);
    $cast(req_pkt_s.PCrd_Type               , PCrdType);
    $cast(req_pkt_s.order                   , Order);
    $cast(req_pkt_s.Allow_Retry	            , 1); // Need to discuss with Satish
    $cast(req_pkt_s.Likely_Shared           , LikelyShared);
    $cast(req_pkt_s.NS		            , NS);
    $cast(req_pkt_s.addr                    , addr);
    $cast(req_pkt_s.size                    , Size);
    $cast(req_pkt_s.opcode                  , cmd);
    $cast(req_pkt_s.TxnID                   , TxnID);
    $cast(req_pkt_s.TgtID                   , TgtID); //ID of the Home Node
    $cast(req_pkt_s.Qos                     ,  QoS);
    $display($time, "CHI_EMU_IF_READ : rsvdc is = %h \n trace_tag = %h \n exp_comp_ack = %h \n excl = %h \n lpid = %h \n snp_attr = %h \n
                 mem_attr = %h \n pcrd = %h \n order = %h \n allow_retry = %h \n likely_shared = %h \n ns = %h \n addr = %h \n
                 size = %h \n opcode = %h \n txnid = %h \n tgtid = %h \n qos = %h \n",req_rsvdc, req_tracetag,ExCompAck, Excl, LPID, SnpAttr, MemAttr, PCrdType, Order, Retry, LikelyShared, NS,addr,Size,cmd,TxnID,TgtID,QoS );

    wr_data_pkt_s.valid                              = 1'b0 ;
    rd_data_pkt_s.valid                              = 1'b0 ;
    primary_rsp_pkt_s.valid                          = 1'b0 ;
    secondary_rsp_pkt_s.valid                        = 1'b0 ;
    mgc_chi_rn_if_0.wait_for_clk (10);
    mgc_chi_rn_if_0.send_txn(req_pkt_s,rd_data_pkt_s,wr_data_pkt_s,primary_rsp_pkt_s,secondary_rsp_pkt_s,0); 
    $display($time," CHI_EMU_READ_TASK : addr is %h data is %h req_qos is %h dat_qos %h",req_pkt_s.addr,rd_data_pkt_s.data,req_pkt_s.Qos,wr_data_pkt_s.Qos); 

   if(rd_data_pkt_s.valid == 1)
    begin
        rdata = rd_data_pkt_s.data;
        $display($time,"In RNF read data is %0h", rdata);
    end
  
 endtask
task chi0_req_rdat64(
    integer 		timestamp,
    bit			nb,
    bit [5:0] 		cmd,
    bit  	[(CHI_REQ_ADDR_WIDTH - 1) : 0] 	addr,
    bit [2:0] 		Size,
    bit 			ExCompAck,
    bit 			Excl,  	// tonyt: excl SnoopMe
    bit [4:0] 		LPID,
    bit [1:0] 		SnpAttr,
    bit 			Device,
    bit 			EWA,
    bit 			Cacheable,
    bit 			Allocate,
    bit [1:0] 		PCrdType,
    bit [1:0] 		Order,	
    bit 			Retry,
    bit 			LikelyShared,
    bit [1:0] 		NS,
    bit [2:0] 		ReturnTxnID,
    bit 			StashNIDValid,
    bit 			ReturnNID, // tonyt: 6/28: spec 7 to 11???
    bit [7:0] 		TxnID,
    bit  	[(CHI_NODE_ID_WIDTH - 1) :0]  	SrcID,
    bit  	[(CHI_NODE_ID_WIDTH - 1) :0]  	TgtID,
    bit [3:0] 		QoS
);

    automatic vtl_chi_req_pkt_s req_pkt_s;
    automatic vtl_chi_rsp_pkt_s primary_rsp_pkt_s ;
    automatic vtl_chi_rsp_pkt_s secondary_rsp_pkt_s ;
    automatic vtl_chi_data_pkt_s wr_data_pkt_s ;
    automatic vtl_chi_data_pkt_s rd_data_pkt_s ;
    bit	      nb_tmp;
    bit [3:0] chi_id;
    bit [(DATA_WIDTH_SEL*CHI_DATA_WIDTH - 1)	: 0]	rdata;  // tonyt: 
    $display ("=================================================\n");
    $display ("Hello from chi_req_rdat with params:\n");
    $display ("Addr = %x \n", addr);
    //Todo bote Check: Retry, ReturnTxnId, StandNIDValid, ReturnID not used
    $cast(req_pkt_s.RSVDC                   , 0);
    $cast(req_pkt_s.Trace_Tag               , 0);
    $cast(req_pkt_s.Exp_Comp_Ack            , ExCompAck);
    $cast(req_pkt_s.Excl_or_Snoop_Me        , Excl);
    $cast(req_pkt_s.LPID                    , LPID);
    $cast(req_pkt_s.Snp_Attr                , SnpAttr);
    //tonyt $cast(req_pkt_s.Mem_Attr	    , MemAttr);
    $cast(req_pkt_s.Mem_Attr                , {Allocate, Cacheable, Device, EWA});
    $cast(req_pkt_s.PCrd_Type               , PCrdType);
    $cast(req_pkt_s.order                   , Order);
    // tonyt: $cast(req_pkt_s.Allow_Retry             , 0);			
    $cast(req_pkt_s.Allow_Retry             , 1);	//[JU] added here - i do not know why..
    //tonyt $cast(req_pkt_s.Allow_Retry	    , Retry);
    $cast(req_pkt_s.Likely_Shared           , LikelyShared);
    $cast(req_pkt_s.NS		            , NS);
    $cast(req_pkt_s.addr                    , addr);
    $cast(req_pkt_s.size                    , Size);
    $cast(req_pkt_s.opcode                  , cmd);
    req_pkt_s.Qos                                     = 4'b0 ;
    $cast(req_pkt_s.Qos                     , QoS);
    req_pkt_s.TgtID               	= TgtID;
    req_pkt_s.TxnID                  	= TxnID;
    nb_tmp = nb;
    chi_id = SrcID[2:0];
    wr_data_pkt_s.valid                              = 1'b0 ;
    rd_data_pkt_s.valid                              = 1'b0 ;
    primary_rsp_pkt_s.valid                          = 1'b0 ;
    secondary_rsp_pkt_s.valid                        = 1'b0 ;
   $display("Testbench :: Starting %p  Transaction for address %x on RN-%p with nb=%p", req_pkt_s.opcode, addr, chi_id, nb_tmp);
   print_request(req_pkt_s);
// tonyt: workaround nonconstant index into instance array:
     mgc_chi_rn_if_0.send_txn(req_pkt_s,rd_data_pkt_s,wr_data_pkt_s,primary_rsp_pkt_s,secondary_rsp_pkt_s,nb_tmp); 
    if(rd_data_pkt_s.valid == 1)
      begin
        // tonyt: 
        rdata = rd_data_pkt_s.data;
      $display("Testbench :: ----> Data = %x", rdata);
        print_data(rd_data_pkt_s);
      end
    
      if(primary_rsp_pkt_s.valid == 1)
      begin
        print_response(primary_rsp_pkt_s);
      end
    
      if(secondary_rsp_pkt_s.valid == 1)
      begin
        print_response(secondary_rsp_pkt_s);
      end
    
      $display("Testbench :: %p on Address = %x gets Data = %x", req_pkt_s.opcode, addr, rdata);
    
        mgc_chi_rn_if_0.wait_for_clk (10);
    
endtask


task chi_req_wrdat_chk_diff(
   integer 		timestamp,
   bit			nb,
   bit [(WDATA - 1)	: 0]	data,
   bit [(WDATA/8 - 1)	: 0]	ByteEnb,
   bit [5:0] 		cmd,
   input bit [(WADDR - 1) 	: 0] 	addr,
   bit [2:0] 		Size,
   bit 			ExCompAck,
   bit 			Excl,  	
   bit [4:0] 		LPID,
   bit [1:0] 		SnpAttr,
   bit [3:0]               MemAttr,
   bit [1:0] 		PCrdType,
   bit [1:0] 		Order,	
   bit 			Retry,
   bit 			LikelyShared,
   bit [1:0] 		NS,
   bit [2:0] 		ReturnTxnID,
   bit 			StashNIDValid,
   bit 			ReturnNID, 
   bit [7:0] 		TxnID,
   bit [(WSRCID - 1) 	: 0]  	SrcID,
   bit [(WSRCID - 1) 	: 0]  	TgtID,
   bit [3:0] 		QoS,
   bit [3:0] req_rsvdc,
   bit req_tracetag,
   bit [3:0] dat_rsvdc,
   bit dat_tracetag,
   bit [2:0] dat_dataid,
   bit [(WTXNID - 1) : 0]dat_dbid,
   bit [2:0] dat_datapull,
   bit [2:0] dat_resp,
   bit [(512/WDATA - 1) : 0] dat_resperr,
   bit [3:0] dat_opcode,
   bit [(WSRCID - 1) :0] dat_homenid,
   bit [7:0] dat_txnid,
   bit [(WSRCID- 1) : 0] dat_tgtid,
   bit [3:0] dat_qos
);

    automatic vtl_chi_req_pkt_s req_pkt_s;
    automatic vtl_chi_rsp_pkt_s primary_rsp_pkt_s ;
    automatic vtl_chi_rsp_pkt_s secondary_rsp_pkt_s ;
    automatic vtl_chi_data_pkt_s wr_data_pkt_s ;
    automatic vtl_chi_data_pkt_s rd_data_pkt_s ;

    bit	nb_tmp;
    bit [3:0] chi_id;
    bit [2:0] dataid;
    bit [(WDATA - 1)	: 0]	wdata;
    bit [(WDATA - 1)	: 0]	rdata;   
    bit [511	: 0]	w_data;   
    bit [63 : 0]	w_byteenb;   
    wdata = data; // saved write data for checking 
    w_data = data;  
    w_byteenb = ByteEnb;  

    $cast(req_pkt_s.RSVDC                   , req_rsvdc);
    $cast(req_pkt_s.Trace_Tag               , req_tracetag);
    $cast(req_pkt_s.Exp_Comp_Ack            , ExCompAck);
    $cast(req_pkt_s.Excl_or_Snoop_Me        , Excl);
    $cast(req_pkt_s.LPID                    , LPID);
    $cast(req_pkt_s.Snp_Attr                , SnpAttr);
    $cast(req_pkt_s.Mem_Attr	            , MemAttr);
   // $cast(req_pkt_s.Mem_Attr	            , 'h2);
    $cast(req_pkt_s.PCrd_Type               , PCrdType);
    $cast(req_pkt_s.order                   , Order);
    $cast(req_pkt_s.Allow_Retry	            , 1);
    $cast(req_pkt_s.Likely_Shared           , LikelyShared);
    $cast(req_pkt_s.NS		            , NS);
    $cast(req_pkt_s.addr                    , addr);
    $cast(req_pkt_s.size                    , Size);
    $cast(req_pkt_s.opcode                  , cmd);
    $cast(req_pkt_s.TxnID                   , TxnID);
    $cast(req_pkt_s.TgtID                   , TgtID); //ID of the Home Node
    $cast(req_pkt_s.Qos                     ,  QoS);

     wr_data_pkt_s.data[0]                              = w_data[127:0];     // tonyt 11/29: 
     wr_data_pkt_s.data[1]                              = w_data[255:128];   // tonyt 11/29: 
     wr_data_pkt_s.data[2]                              = w_data[383:256];   // tonyt 11/29: 
     wr_data_pkt_s.data[3]                              = w_data[511:384];
     
     
     wr_data_pkt_s.BE[0]                               = w_byteenb[15:0];    // tonyt 11/29:  
     wr_data_pkt_s.BE[1]                               = w_byteenb[31:16];   // tonyt 11/29: 
     wr_data_pkt_s.BE[2]                               = w_byteenb[47:32];   // tonyt 11/29:
     wr_data_pkt_s.BE[3]                               = w_byteenb[63:48];  

    wr_data_pkt_s.RSVDC                              = dat_rsvdc ;    
    wr_data_pkt_s.DataID                             = dat_dataid; 
    wr_data_pkt_s.Trace_Tag                          = dat_tracetag ;
    wr_data_pkt_s.CCID                               = addr[5:4] ;     
    wr_data_pkt_s.DBID                               = dat_dbid ;     
    wr_data_pkt_s.FwdState_or_DataPull_or_DataSource = dat_datapull ;
    wr_data_pkt_s.Resp                               = dat_resp ;  
    wr_data_pkt_s.Resp_Err                           = dat_resperr ;
    $cast(wr_data_pkt_s.opcode                       , dat_opcode);
    wr_data_pkt_s.HomeNID                            = dat_homenid ; 
    wr_data_pkt_s.TxnID                              = TxnID ;   // This shall be updated in the hardware ...
    wr_data_pkt_s.TgtID                              = dat_tgtid;   
    wr_data_pkt_s.Qos                                = dat_qos;     
    wr_data_pkt_s.valid                              = 1'b1 ;

    rd_data_pkt_s.valid                              = 1'b0 ;
    primary_rsp_pkt_s.valid                          = 1'b0 ;
    secondary_rsp_pkt_s.valid                        = 1'b0 ;

    $display($time, " CHI_EMU_IF : WRITE_TASK_DIFF data_id is %0h %0h %0h %0h",dataid,dataid+2'h1,dataid+2'h2,dataid+2'h3);
    print_request(req_pkt_s);
    print_data(wr_data_pkt_s);

    mgc_chi_rn_if_0.wait_for_clk (10);
    mgc_chi_rn_if_0.send_txn(req_pkt_s,rd_data_pkt_s,wr_data_pkt_s,primary_rsp_pkt_s,secondary_rsp_pkt_s,0); 
    mgc_chi_rn_if_0.wait_for_clk (10);

    $display($time," CHI_WRITE_TASK_DIFF : addr is %h data is %h req_qos is %h dat_qos %h data_txnid is %0h data_opcode is %s resp is %0h resp_err is %0h",req_pkt_s.addr,wr_data_pkt_s.data,req_pkt_s.Qos,wr_data_pkt_s.Qos,wr_data_pkt_s.TxnID,wr_data_pkt_s.opcode.name(),wr_data_pkt_s.Resp,wr_data_pkt_s.Resp_Err); 

endtask
endinterface: <%=obj.BlockId%>_chi_emu_if

<% } %>

