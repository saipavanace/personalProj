
//`ifndef AXI_STL_TRAFFIC
//`define AXI_STL_TRAFFIC
////////////////////////////////////////////////////////////////////////////////
//
// AXI Read STL file
//
////////////////////////////////////////////////////////////////////////////////
<% var this_aiu_id = obj.Id; 
if (obj.NctiAgent === 1) {
    this_aiu_id = obj.Id + obj.AiuInfo.length + obj.BridgeAiuInfo.length;
}
%>
<% var found_me      = 0;
   var my_ioaiu_id   = 0;

   for (var idx=0; idx < obj.AiuInfo.length; idx++) {
      if (obj.AiuInfo[idx].fnNativeInterface.indexOf("CHI") < 0) {
         if (obj.Id == idx) {
            found_me = 1;
         } else if (! found_me) {
            my_ioaiu_id ++;
         }   
      }
   }
%>

`ifdef USE_STL_TRACE
task axi_stl_format_read(output int idle_cnt_q[$],output int response_q[$],output bit[63:0] stl_wr_q[$],output bit[63:0] stl_rd_q[$],output int wr_txn_cnt,output int rd_txn_cnt);
   <%=obj.BlockId%>_axi_agent_pkg::axi_arid_t arid;
   <%=obj.BlockId%>_axi_agent_pkg::axi_awid_t awid;
   <%=obj.BlockId%>_axi_agent_pkg::axi_axaddr_t address;
   <%=obj.BlockId%>_axi_agent_pkg::axi_axqos_t QOS_t;
   <%=obj.BlockId%>_axi_agent_pkg::axi_xdata_t data;
    integer outfile0;

    int idle_count,rsp_line,stl_format,beat_t,arburst,awburst;
    string line,trans_type,wait_st,rsp_st,burst_type,data_type;
    string CACHE, BUF,CACHE_WR_ALOC, CACHE_RD_ALOC, LOCK, QOS,SNOOP,BURST_SIZE;
    int SNOOP_t, LOCK_t,CACHE_t,BUF_t,CACHE_WR_ALOC_t, CACHE_RD_ALOC_t;
    string regex,str,rsp,idle,beat,burst_t;
    bit first_txn,last_txn;
    int BURST_SIZE_t;
    string stl_file_name;
    
    `ifdef STL_FILE_FULL_PATH  
    `define STRING_STL_FILE_FULL_PATH `"`STL_FILE_FULL_PATH`"
    `uvm_info("STL::AXI",$psprintf("STL::starting stl AXI transactions %s ",`STRING_STL_FILE_FULL_PATH),UVM_NONE)
    `endif
    stl_file_name ="acc<%=my_ioaiu_id%>.stl";
    outfile0=$fopen({`STRING_STL_FILE_FULL_PATH,stl_file_name},"r");
    if(outfile0) begin
   `uvm_info("STL::AXI",$psprintf("STL::AXI file opened successfully"),UVM_NONE)
    //else `uvm_error("STL::AXI",$sformatf("STL::unable to open STL file for register configurations"));//Interface without stl files should be in inactive state

    $fgets (line, outfile0); //Get entire line
    `uvm_info("STL::AXI",$psprintf("STL::Comment line= %s",line),UVM_NONE)

    while (!$feof(outfile0)) begin // find out identifier for reg
    $fscanf(outfile0," %s ", str);
    //match - returns 0 on success
    regex="idle*";
    if(!(uvm_re_match(regex,str))) stl_format=1;
    regex="wait*";
    if(!(uvm_re_match(regex,str))) stl_format=2;
    
    case(stl_format)
    1 : begin
        $fscanf(outfile0,"%d ",idle_count);
        `uvm_info("STL::AXI",$psprintf("STL::AXI idlecycles =%d ", idle_count),UVM_NONE) //Get idle cycle count
        stl_format=0;
        idle_cnt_q.push_back(idle_count);
        first_txn=1;
        last_txn=0;
    end
    2 : begin
        $fscanf(outfile0,"%s %h ",rsp,rsp_line);
        `uvm_info("STL::AXI",$psprintf("STL::AXI waiting for response %s =%h ", rsp,rsp_line),UVM_NONE) //Get wait rsp line
        stl_format=0;
        response_q.push_back(rsp_line);
        $fgets (line, outfile0); //Get entire line
        `uvm_info("STL::AXI",$psprintf("STL::Comment line= %s",line),UVM_NONE)
        $fgets (line, outfile0); //Get entire line
        `uvm_info("STL::AXI",$psprintf("STL::Comment line= %s",line),UVM_NONE)
        last_txn=1;
        case(trans_type)
        "bread" : begin
            stl_rd_q.pop_back();
            stl_rd_q.push_back(last_txn);
        end
        "bwrite" : begin
            stl_wr_q.pop_back();
            stl_wr_q.push_back(last_txn);
        end
        endcase
    end
    default : begin //bread

        $fscanf(outfile0," %s %s %s ",beat,burst_type, trans_type);

        `uvm_info("STL::AXI",$psprintf("STL::AXI generating transaction %d %s %s",beat,burst_type, trans_type),UVM_NONE) 

        if(trans_type=="bread") begin //read txn
            $fscanf(outfile0,"%h  %s %s  %s  %s  %s %s %s ",address,CACHE,BUF,CACHE_WR_ALOC,CACHE_RD_ALOC,BURST_SIZE,LOCK,QOS);
            `uvm_info("STL::AXI",$psprintf("STL::AXI txn_num= %s txn_beats=%d burst_type=%s txn_type=%s araddr=%h  %s %s  %s  %s  %s %s %s ",str,beat,burst_type, trans_type,address,CACHE,BUF,CACHE_WR_ALOC,CACHE_RD_ALOC,BURST_SIZE,LOCK,QOS),UVM_NONE)

            //extract fields from string
            burst_t = burst_type.substr(0, burst_type.len()-2);
            if(burst_t=="INCR") arburst=1;
            if(burst_t=="WRAP") arburst=2;
            arid=str.atoi();

            if (($sscanf(beat, "(%0d", beat_t) == 1)  && ($sscanf(CACHE, "CACHE:%d", CACHE_t) == 1) && ($sscanf(BUF, "BUF:%d", BUF_t) == 1) && ($sscanf(CACHE_WR_ALOC, "CACHE_WR_ALOC:%d", CACHE_WR_ALOC_t) == 1) && ($sscanf(CACHE_RD_ALOC, "CACHE_RD_ALOC:%d", CACHE_RD_ALOC_t) == 1) && ($sscanf(BURST_SIZE, "BURST_SIZE:%0d", BURST_SIZE_t) == 1) && ($sscanf(LOCK, "LOCK:%d", LOCK_t) == 1) && ($sscanf(QOS, "QOS:%d", QOS_t) == 1))

             `uvm_info("STL::AXI",$psprintf("STL::AXI timestamp= %0h beats=%0h burst_type=%0s,axi transaction= %s araddr= %0h CACHE=%0h BUF=%0h CACHE_WR_ALOC=%0h CACHE_RD_ALOC=%0h BURST_SIZE=%0h LOCK=%0h QOS=%0h", str,beat_t,burst_t,trans_type,address,CACHE_t,BUF_t,CACHE_WR_ALOC_t,CACHE_RD_ALOC_t,BURST_SIZE_t,LOCK_t,QOS_t),UVM_NONE)
              stl_rd_q.push_back(first_txn);
              if(first_txn==1) stl_rd_q.push_back(idle_count);
              stl_rd_q.push_back(arid);
              stl_rd_q.push_back(beat_t);
              stl_rd_q.push_back(address);
              stl_rd_q.push_back(arburst);
              stl_rd_q.push_back(CACHE_t);
              stl_rd_q.push_back(BUF_t);
              stl_rd_q.push_back(CACHE_WR_ALOC_t);
              stl_rd_q.push_back(CACHE_RD_ALOC_t);
              stl_rd_q.push_back(BURST_SIZE_t);
              stl_rd_q.push_back(LOCK_t);
              stl_rd_q.push_back(QOS_t);
              stl_rd_q.push_back(last_txn);
              rd_txn_cnt++;
         end

         if(trans_type=="bwrite") begin//write txn
            $fscanf(outfile0,"%h  %s %s  %s  %s  %s %s %s ",address,CACHE,BUF,CACHE_WR_ALOC,CACHE_RD_ALOC,BURST_SIZE,LOCK,QOS);
            `uvm_info("STL::AXI",$psprintf("STL::AXI txn_num= %s txn_beats=%d burst_type=%s txn_type=%s araddr=%h  %s %s  %s  %s  %s %s %s ",str,beat,burst_type, trans_type,address,CACHE,BUF,CACHE_WR_ALOC,CACHE_RD_ALOC,BURST_SIZE,LOCK,QOS),UVM_NONE)

            //extract fields from string
            burst_t = burst_type.substr(0, burst_type.len()-2);
            if(burst_t=="INCR") awburst=1;
            if(burst_t=="WRAP") awburst=2;
            awid=str.atoi();

            if (($sscanf(beat, "(%0d", beat_t) == 1)  && ($sscanf(CACHE, "CACHE:%d", CACHE_t) == 1) && ($sscanf(BUF, "BUF:%d", BUF_t) == 1) && ($sscanf(CACHE_WR_ALOC, "CACHE_WR_ALOC:%d", CACHE_WR_ALOC_t) == 1) && ($sscanf(CACHE_RD_ALOC, "CACHE_RD_ALOC:%d", CACHE_RD_ALOC_t) == 1) && ($sscanf(BURST_SIZE, "BURST_SIZE:%d", BURST_SIZE_t) == 1) && ($sscanf(LOCK, "LOCK:%d", LOCK_t) == 1) && ($sscanf(QOS, "QOS:%d", QOS_t) == 1))

            `uvm_info("STL::AXI",$psprintf("STL::AXI timestamp= %0h beats=%0h burst_type=%0s,axi transaction= %s awaddr= %0h CACHE=%0h BUF=%0h CACHE_WR_ALOC=%0h CACHE_RD_ALOC=%0h BURST_SIZE=%0h LOCK=%0h QOS=%0h", str,beat_t,burst_t, trans_type,address,CACHE_t,BUF_t,CACHE_WR_ALOC_t,CACHE_RD_ALOC_t,BURST_SIZE_t,LOCK_t,QOS_t),UVM_NONE)
            stl_wr_q.push_back(first_txn);
            if(first_txn==1) stl_wr_q.push_back(idle_count);
            stl_wr_q.push_back(awid);
            stl_wr_q.push_back(beat_t);
            stl_wr_q.push_back(address);
            stl_wr_q.push_back(awburst);
            stl_wr_q.push_back(CACHE_t);
            stl_wr_q.push_back(BUF_t);
            stl_wr_q.push_back(CACHE_WR_ALOC_t);
            stl_wr_q.push_back(CACHE_RD_ALOC_t);
            stl_wr_q.push_back(BURST_SIZE_t);
            stl_wr_q.push_back(LOCK_t);
            stl_wr_q.push_back(QOS_t);
            stl_wr_q.push_back(last_txn);
            wr_txn_cnt++;
         end
         first_txn=0;
         last_txn=0;
     end
   endcase
  end
end
endtask : axi_stl_format_read
`endif //USE_STL_TRACE
//`endif // AXI_STL_TRAFFIC
