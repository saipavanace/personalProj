
<%if(obj.isBridgeInterface){ %>
parameter CCP_ADDR_WIDTH = 32;
<%}else{%>
parameter CCP_ADDR_WIDTH = <%= obj.DmiInfo[0].wAddr %>;
<%}%>




 function longint mapAddrToCCPTag(input bit [CCP_ADDR_WIDTH-1:0]  address);

    longint cacheTag;
    cacheTag = address[WCCPADDR-1:CACHELINE_OFFSET];
   
    return cacheTag;
    

endfunction



