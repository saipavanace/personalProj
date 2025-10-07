
///////////////////////////////////////////////////////////////////////////////
//                                                                           //  
// File         :   ccp_cache_model.sv                                       //
// Description  :   Cache model for IO cache.                                //
//                                                                           //
// Revision     :                                                            //
//                                                                           //
//                                                                           //
//                                                                           // 
///////////////////////////////////////////////////////////////////////////////

typedef class ccpCacheLine;
class ccp_cache_model extends uvm_object;
    `uvm_object_utils(ccp_cache_model)

    parameter ADDR_WIDTH        =   WCCPADDR-1;
    parameter DATA_WIDTH        =   WCCPDATA;
    parameter NO_OF_SETS        =   <%=obj.nSets%>; 
    parameter NO_OF_WAYS        =   <%=obj.nWays%>; 
    parameter INDEX_LOW         =   <%=obj.wCacheLineOffset%>;
    <%if(obj.nSets>2){%>
    parameter INDEX_SIZE        =   $clog2(NO_OF_SETS);
    parameter INDEX_HI          = INDEX_SIZE+INDEX_LOW-1;
    <%}else{%>
    parameter INDEX_SIZE        =   0;
    parameter INDEX_HI          = INDEX_LOW;
    <%}%>
/*
   <% if((obj.Block === "io_aiu" && obj.useCache) || (obj.Block === "dmi" && obj.useCmc)) { %>                           
    parameter NO_OF_SETS        =   <%=obj.nSets%>; 
    parameter NO_OF_WAYS        =   <%=obj.nWays%>; 
    parameter INDEX_LOW         =   <%=obj.wCacheLineOffset%>;
    <%if(obj.nSets>2){%>
    parameter INDEX_SIZE        =   $clog2(NO_OF_SETS);
    parameter INDEX_HI          = INDEX_SIZE+INDEX_LOW-1;
    <%}else{%>
    parameter INDEX_SIZE        =   0;
    parameter INDEX_HI          = INDEX_LOW;
    <%}%>
    <%}else{%>
    parameter NO_OF_SETS        = 0;
    parameter NO_OF_WAYS        = 2;
    parameter INDEX_SIZE        = 0;
    parameter INDEX_LOW         = 6;
    parameter INDEX_HI          = INDEX_LOW+1;
    <%}%>
*/     
    typedef bit [NO_OF_WAYS-1:0]                    nru_t;
    typedef bit [NO_OF_WAYS-1:0]                    nru_cnt_t;
    typedef ccpCacheLine                            ccpCacheLine_a[];

    int NO_OF_SP_WAYS=0;
    string block = "<%=obj.Block%>";
    int ways = <%=obj.nWays%>;
    
    ccpCacheLine_a                                  ccpCacheSet[int];
    nru_t                                           nru_bit_q[int];
    ccp_ctrlwr_data_t                               m_data[];
    typedef ccp_ctrlwr_data_t                       data_t[BURSTLN];
    typedef bit                                     dataErrorPerBeat_t[BURSTLN];
    typedef ccp_ctrlwr_byten_t                      wstrb_t;

    //addr_trans_mgr                                  m_addr_mgr;
    
    function new(string name="ccpCacheModel");
        super.new(name);
        //m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction

    
    //============================================================================
    // Name    : add_cacheline
    // Purpose : Add a cacheline to the IO Cache Model.
    // The function should be called by a read-miss allocate or write-miss
    // allocate
    // Make sure to initialize the NRU bit and CNT array.
    //============================================================================
    
    function add_cacheline(bit [ADDR_WIDTH:0] ccpAddr, ccp_cachestate_enum_t ccpState, 
                           bit pending, logic security,input int wayn);
        ccpCacheLine temp;
        int index;
        longint iotag;
        string spkt;
        int fq[$]; 

        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag = mapAddrToCCPTag(ccpAddr);
    `uvm_info("CACHE MODEL",$sformatf("m_ccpAddr :%0x ccpAddr_tag :%0x ccp_index :%0x ccpState :%s",ccpAddr,iotag,index,ccpState.name()),UVM_HIGH); 

        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_first_index() with (
                 (item.state == IX) && (item.isPending == 1'b0)); 
            if(fq.size() > 0 ) begin
                temp                     = new("temp_cacheline");
                temp.addr                = ccpAddr;
                temp.state               = ccpState;
                temp.isPending           = pending;
                temp.Index               = index;
                temp.tag                 = iotag;
                temp.way                 = wayn;
                temp.security            = security;
                temp.data                = ccpCacheSet[index][wayn].data;
                temp.dataErrorPerBeat    = ccpCacheSet[index][wayn].dataErrorPerBeat;
                //NF: Instead of first available way, use the way observed in incoming packet
                //TODO: Add check to make sure cacheline in this way is IX state or has same addr & is transitioning to correct states.
                //ccpCacheSet[index][fq[0]] = temp;
                ccpCacheSet[index][wayn] = temp;
                `uvm_info("ADD_CACHELINE",$psprintf("%s",
                         ccpCacheSet[index][wayn].sprint_pkt()),UVM_MEDIUM)
            
            end else begin 
                spkt = {"Ohh no IO cache have all ways taken. Are you sure you",
                        " want to add the cacheline at %0h"};
                `uvm_fatal("CCP_CACHE_MODEL", $psprintf(spkt,ccpAddr))
            end
        end else begin 
            spkt = {"You are having a tough day. Sorry the cache index you asked",
                     "for doesn't exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction
    
    //============================================================================
    // Name    : initCacheIndex
    // Purpose : Initialize a particular cache index. 
    //           
    // 
    //============================================================================
    function bit initCacheIndex(bit [ADDR_WIDTH:0] ccpAddr);
        string spkt;
        ccpCacheLine temp;
        int index;
        longint iotag;

        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);

        if(ccpCacheSet.exists(index)) begin 
             spkt = {"Initalization of cache index is only allowed for cache",
                      " index that are not present in the cache model. I did",
                      " find a cache index for the address that you provided"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt) 
        end else begin 
            ccpCacheSet[index]    = new[NO_OF_WAYS];
            //Initialize the index 
            //Required since the find_index_with requires this
            //else getting null pointer error.
            for(int i=0;i<NO_OF_SP_WAYS;i++) begin
                temp                  = new("temp_cacheline");
                temp.addr             = 'x;
                temp.data             = new[BURSTLN];
                temp.dataErrorPerBeat = new[BURSTLN];
                temp.state            = IX;
                temp.Index            = index;
                temp.tag              = 'x;
                temp.way              = i;
                temp.security         = 1'bx;
                temp.isPending        = 1;
                ccpCacheSet[index][i]  = temp;
            end
            for(int i=NO_OF_SP_WAYS;i<NO_OF_WAYS;i++) begin
                temp                  = new("temp_cacheline");
                temp.addr             = '0;
                temp.data             = new[BURSTLN];
                temp.dataErrorPerBeat = new[BURSTLN];
                temp.state            = IX;
                temp.Index            = index;
                temp.tag              = '0;
                temp.way              = i;
                temp.security         = 1'bx;
                ccpCacheSet[index][i]  = temp;
            end
            nru_bit_q[index]         = '0;
            //`uvm_info("DEBUG",$psprintf("INDEX:%0b",index),UVM_MEDIUM)
        end 
    
    endfunction

    //============================================================================
    // Name    : isCacheIndexValid
    // Purpose : It checks if the cacheline index is initialized.
    // 
    //============================================================================

    function bit isCacheIndexValid(bit [ADDR_WIDTH:0] ccpAddr);
        //int index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        int index =  CcpCalcIndex(ccpAddr);

        if(ccpCacheSet.exists(index)) 
            return(1'b1);
        else 
            return(1'b0);
    endfunction

    //============================================================================
    // Name    : chkFirstAvailWay
    // Purpose : check for the first available way.
    // 
    //============================================================================

    function chkFirstAvailWay(input bit [ADDR_WIDTH:0] ccpAddr, input bit [NO_OF_WAYS-1:0] busyway, output int way);
        int fq[$]; 
        string spkt;
        bit found;
        //int index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        int index =  CcpCalcIndex(ccpAddr);

         //print_cache_model();
         found = 0;
         if(ccpCacheSet.exists(index)) begin
            for(int i=0; i<NO_OF_WAYS;i++) begin
               if(busyway[i]==0) begin
                  for (int j=0; j<NO_OF_WAYS; j++) begin
                     if ((ccpCacheSet[index][j].way == i) && (((ccpCacheSet[index][j].isInvldPending==0) && (ccpCacheSet[index][j].state!=IX))
                         || (ccpCacheSet[index][j].isPending==1))) begin
                        found = 0;
                        break;
                     end else if ((ccpCacheSet[index][j].way == i) && ((ccpCacheSet[index][j].isInvldPending==1) || (ccpCacheSet[index][j].state==IX))
                                  && (ccpCacheSet[index][j].isPending==0)) begin
                        way = i;
                        found = 1;
                     end
                  end
               end
               if (found) break;
            end
            if (!found) begin
                spkt = {"All ways are taken for Index:%0h and Addr:%0h",
                         " Did you forget to evict a cacheline?"};
                `uvm_error("CCP_CACHE_MODEL",spkt)
            end
        end else begin  
            spkt = {"You are having a tough day. Sorry the cache index you asked",
                     "for doesn't exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction

    //============================================================================
    // Name    : isCacheLineValid
    // Purpose : It checks if the cacheline state is not IX and return 0 if 
    //           the state is IX else returns 1. 
    // 
    //============================================================================

    function bit isCacheLineValid(bit [ADDR_WIDTH:0] ccpAddr, logic security);
        int fq[$]; 
        longint iotag;
        int index; 
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag = mapAddrToCCPTag(ccpAddr);

        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                 (item.tag == iotag) &&
                 (item.security == security));
            
            if(fq.size() > 0) begin
                if(ccpCacheSet[index][fq[0]].state          != IX &&
                   ccpCacheSet[index][fq[0]].isInvldPending == 0 &&
                   ccpCacheSet[index][fq[0]].isPending      == 0 )
                    return(1'b1);
                else 
                    return(1'b0);
            end else 
                return(1'b0);
        end else 
            return(1'b0);
    endfunction

    //============================================================================
    // Name    : isCacheIndexFull
    // Purpose : Counts the number of cacheline which are not in IX state. If the  
    //           count is equal to the NO_OF_WAYS it return 1 else 0.
    // 
    //============================================================================

    function bit isCacheIndexFull(input bit [ADDR_WIDTH:0] ccpAddr, input bit [NO_OF_WAYS-1:0] busyway=0);
        int fq[$];
        string spkt;
        int index;
        bit found;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);

        `uvm_info("CACHE MODEL",$sformatf("m_ccpAddr :%0x ccp_index :%0x",ccpAddr,index),UVM_MEDIUM); 
        found = 0;
        if(ccpCacheSet.exists(index)) begin
            for(int i=0; i<NO_OF_WAYS;i++) begin
               if(busyway[i]==0) begin
                  for (int j=0; j<NO_OF_WAYS; j++) begin
                     if ((ccpCacheSet[index][j].way == i) && (((ccpCacheSet[index][j].isInvldPending==0) && (ccpCacheSet[index][j].state!=IX))
                         || (ccpCacheSet[index][i].isPending==1))) begin
                        found = 0;
                        break;
                     end else if ((ccpCacheSet[index][j].way == i) && ((ccpCacheSet[index][j].isInvldPending==1) || (ccpCacheSet[index][j].state==IX))
                                  && (ccpCacheSet[index][j].isPending==0)) begin
                        found = 1;
                     end
                  end
               end
               if (found) break;
            end

            if (!found) return(1'b1);
            else return(1'b0);
        end else begin  
            spkt = {"You are having a tough day. Sorry the cache index you asked",
                     "for doesn't exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
                    
    endfunction

    
    //============================================================================
    // Name    : set_pending_bit
    // Purpose : Used to clear the pending bit.
    // 
    // 
    //============================================================================
    function set_pending_bit(bit [ADDR_WIDTH:0] ccpAddr, bit pending, logic security);
        int fq[$]; 
        longint iotag;
        int index;
        string spkt;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag     = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag) &&
                   //  item.isPending &&
                     (item.security == security)
                 );  

            if(fq.size() == 1 ) begin 
                spkt = {"CacheLine Pending bit for ADDR:%0h changed from %0h to %0h"};
                `uvm_info("CCP_CACHE_MODEL", $psprintf(spkt,ccpCacheSet[index][fq[0]].addr,
                          ccpCacheSet[index][fq[0]].isPending, pending),UVM_MEDIUM)         

                ccpCacheSet[index][fq[0]].isPending = pending;
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue for set_pending_bit cannot be greater than 1")
            end else begin 
                spkt = {"In clear pending bit function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                "exists"};
            `uvm_fatal("CCP_CACHE_MODEL", spkt)
        end
   endfunction

    //============================================================================
    // Name    : set_pending_bit
    // Purpose : Used to clear the pending bit.
    // 
    // 
    //============================================================================
    function set_invldpending_bit(bit [ADDR_WIDTH:0] ccpAddr, bit pending, logic security);
        int fq[$]; 
        longint iotag;
        int index;
        string spkt;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag     = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag) &&
                     (item.security == security)
                 );  

            if(fq.size() == 1 ) begin 
                spkt = {"CacheLine  InvldPending bit for ADDR:%0h changed from %0h to %0h"};
                `uvm_info("CCP_CACHE_MODEL", $psprintf(spkt,ccpCacheSet[index][fq[0]].addr,
                          ccpCacheSet[index][fq[0]].isInvldPending, pending),UVM_MEDIUM)         

                ccpCacheSet[index][fq[0]].isInvldPending = pending;
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue for set_pending_bit cannot be greater than 1")
            end else begin 
                spkt = {"In clear pending bit function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                "exists"};
            `uvm_fatal("CCP_CACHE_MODEL", spkt)
        end
   endfunction
    
    //============================================================================
    // Name    : allWaysTaken
    // Purpose : Counts the number of isPending bit to check if all ways
    //           are pending. If all ways are taken then this should be no-alloc
    // 
    //============================================================================
    function bit allWaysTaken(bit [ADDR_WIDTH:0] ccpAddr);
        int fq[$]; 
        string spkt;
        //int index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        int index =  CcpCalcIndex(ccpAddr);

        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                 item.isPending  == 1'b1); 
            
            if(fq.size() == NO_OF_WAYS) 
                return(1'b1);
            else 
                return(1'b0);
        end else begin  
            spkt = {"You are having a tough day. Sorry the cache index you asked",
                     "for doesn't exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
                    
    endfunction

    
    //============================================================================
    // Name    : modify_state
    // Purpose : Used to modify the state of the cacheline. 
    // 
    // 
    //============================================================================
    function modify_state(bit [ADDR_WIDTH:0] ccpAddr, ccp_cachestate_enum_t ccpState, logic security);
        int fq[$]; 
        longint iotag;
        int index;
        string spkt;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag     = mapAddrToCCPTag(ccpAddr);
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag) &&
                     (item.security == security)
                 );  

            if(fq.size() == 1 ) begin 
                `uvm_info("CCP_CACHE_MODEL", $psprintf("CacheLine State for ADDR:%0h changed from %0p to %0p",
                        ccpCacheSet[index][fq[0]].addr,ccpCacheSet[index][fq[0]].state, ccpState),UVM_MEDIUM)         
                ccpCacheSet[index][fq[0]].state = ccpState;
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue for modify_state cannot be greater than 1")
            end else begin 
                spkt = {"In modify_state function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                "exists"};
            `uvm_fatal("CCP_CACHE_MODEL", spkt)
        end
   endfunction


    //============================================================================
    // Name    : modify_data
    // Purpose : Fills the cacheline for store.
    //           The function should be called by a write-miss upgrade.
    //
    //============================================================================
    function modify_data(int dataIndex,int dataWay, data_t ioData, dataErrorPerBeat_t ioDataErrorPerBeat);
        int index;
        longint iotag;
        string spkt;
       foreach(ioData[i]) begin
       `uvm_info("CCP_CACHE_MODEL", $psprintf("modify data Index :%0d wayn :%0d data[%0d] :%0x",dataIndex,dataWay,i,ioData[i]),UVM_MEDIUM);
        end
        if( ccpCacheSet.exists(dataIndex)) begin
            ccpCacheSet[dataIndex][dataWay].data             = ioData;
            ccpCacheSet[dataIndex][dataWay].dataErrorPerBeat = ioDataErrorPerBeat;
        end else begin 
            spkt ={"You are having a tough day. Sorry the cache index you asked for doesn't",
                    "exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt);
        end
    endfunction

    
    //============================================================================
    // Name    : give_data
    // Purpose : Function to return the data stored for a particular cacheline. 
    // 
    // 
    //============================================================================
    function give_data(int dataIndex,int dataWay,output data_t ioData, 
                      output dataErrorPerBeat_t ioDataErrorPerBeat);
        int fq[$]; 
        string spkt;
        
        if( ccpCacheSet.exists(dataIndex)) begin
            ioData             = ccpCacheSet[dataIndex][dataWay].data;
            ioDataErrorPerBeat = ccpCacheSet[dataIndex][dataWay].dataErrorPerBeat;
        end else begin 
            spkt ={"You are having a tough day. Sorry the cache index you asked for doesn't",
                    "exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt);
        end
    endfunction 


    //============================================================================
    // Name    : give_state
    // Purpose : Provides the current state of the cacheline. 
    // 
    // 
    //============================================================================
    function give_state(input bit [ADDR_WIDTH:0] ccpAddr,logic security,output ccp_cachestate_enum_t ccpState);
        int fq[$];
        longint iotag;
        int index;
        string spkt;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag     = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag)         &&
                     (item.state != IX)          &&
                     (item.security == security)
                 );

            if(fq.size() == 1 ) begin 
                ccpState = ccpCacheSet[index][fq[0]].state;
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue cannot be greater than 1")
            end else begin 
                spkt = {"In give_state function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin 
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                     "exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction

    //============================================================================
    // Name    : give_cacheline
    // Purpose : Provides a copy of the cacheline for the given addr.
    // 
    // 
    //============================================================================
    function give_cacheline(input bit [ADDR_WIDTH:0] ccpAddr,logic security,output ccpCacheLine cacheLine);
        int fq[$];
        longint iotag;
        string spkt;
        int index;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag     = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag)         &&
                     (item.state != IX)          &&
                     (item.security == security)
                 );

            if(fq.size() == 1 ) begin 
                cacheLine = new;
                cacheLine.copy(ccpCacheSet[index][fq[0]]);
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue for give cacheline cannot be greater than 1")
            end else begin 
                spkt = {"In give_cacheline function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin 
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                     "exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction
    
    
    //============================================================================
    // Name    : give_wayIndex
    // Purpose : Provides a copy of the way
    // 
    // 
    //============================================================================
    function give_wayIndex(input bit [ADDR_WIDTH:0] ccpAddr, logic security,output int way,
                            output int Index);
        int fq[$];
        longint iotag;
        string spkt;
        //int index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        int index =  CcpCalcIndex(ccpAddr);
        iotag     = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag)         &&
                     (item.state != IX)          &&
                     (item.security == security)
                 );

            if(fq.size() == 1 ) begin 
                way = ccpCacheSet[index][fq[0]].way;
                Index = ccpCacheSet[index][fq[0]].Index;
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue for give cacheline cannot be greater than 1")
            end else begin 
                print_cache_model();
                spkt = {"In give_way function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin 
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                     "exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction
    
              
       
    //============================================================================
    // Name    : copy_cacheline
    // Purpose : Deletes the entire cacheline. 
    // 
    //============================================================================
    function copy_cacheline(bit [ADDR_WIDTH:0] ccpAddr,logic security, output ccpCacheLine cpy_cacheline);
        int fq[$];
        longint iotag;
        string spkt;
        int index;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag)         &&
                     ((item.state != IX) && (item.isPending == 0)) &&
                     (item.security == security)
                 );  

            if(fq.size() == 1 ) begin 
                spkt = ccpCacheSet[index][fq[0]].sprint_pkt();
                cpy_cacheline = new;
                cpy_cacheline.copy(ccpCacheSet[index][fq[0]]);
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue cannot be greater than 1")
            end else begin 
                spkt = {"In copy_cacheline function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin
            spkt = {"Ohh no did you really mean to delete this cacheline. Sorry don't have", 
                     "this cacheline so can't copy it. :("};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction

    //============================================================================
    // Name    : delete_cacheline
    // Purpose : Deletes the entire cacheline. 
    // 
    //============================================================================
    function delete_cacheline(bit [ADDR_WIDTH:0] ccpAddr,logic security);
        int fq[$];
        longint iotag;
        string spkt;
        int index;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag)         &&
                     ((item.state != IX) && (item.isPending == 0))       &&
                     (item.security == security)
                 );  

            if(fq.size() == 1 ) begin 
                spkt = ccpCacheSet[index][fq[0]].sprint_pkt();
                `uvm_info("DELETE_CACHELINE",spkt,UVM_MEDIUM)
                ccpCacheSet[index][fq[0]].state          = IX;
                ccpCacheSet[index][fq[0]].addr           = 0;
                ccpCacheSet[index][fq[0]].isPending      = 0;
                ccpCacheSet[index][fq[0]].security       = 1'bx;
                ccpCacheSet[index][fq[0]].tag            = '0;
                ccpCacheSet[index][fq[0]].isInvldPending = '0;
                nru_bit_q[index][fq[0]]                  = 0;
            end else if(fq.size() > 1) begin  
                `uvm_fatal("CCP_CACHE_MODEL", "Find Queue cannot be greater than 1")
            end else begin 
                spkt = {"In delete_cacheline function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin
            spkt = {"Ohh no did you really mean to delete this cacheline. Sorry don't have", 
                     "this cacheline so can't delete it. :("};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction
    //============================================================================
    // Name    : delete_cacheline
    // Purpose : Deletes the entire cacheline when fill inv. 
    // 
    // 
    //============================================================================
    function delete_cacheline_fill(bit [ADDR_WIDTH:0] ccpAddr,logic security,int way);
        int fq[$];
        longint iotag;
        string spkt;
        int index;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag = mapAddrToCCPTag(ccpAddr);
        
        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                     (item.tag == iotag)         &&
                     (((item.state != IX) && (item.isPending == 0)) || ((item.state == IX) && (item.isPending == 1)))       &&
                     (item.security == security)
                 );  

            if(fq.size() >0 ) begin 
                spkt = ccpCacheSet[index][fq[0]].sprint_pkt();
                `uvm_info("DELETE_CACHELINE",spkt,UVM_MEDIUM)
                ccpCacheSet[index][way].state     = IX;
                ccpCacheSet[index][way].addr      = 0;
                ccpCacheSet[index][way].isPending = 0;
                ccpCacheSet[index][way].security  = 1'bx;
                ccpCacheSet[index][way].tag       = '0;
                nru_bit_q[index][way]             = 0;
            end else begin 
                spkt = {"In delete_cacheline function couldn't find the cacheline for Addr:%h"};
                `uvm_error("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr)) 
            end
        end else begin
            spkt = {"Ohh no did you really mean to delete this cacheline. Sorry don't have", 
                     "this cacheline so can't delete it. :("};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction
    
    //============================================================================
    // Name    : update_nru
    // Purpose : On a read hit/write hit update the NRU bits. 
    //           If all bits are set i.e 1101 and we set the 3 bit. I will 
    //           clear all the bits except the 3 bit i.e 0010. The eviction 
    //           logic will look at the bits with 0 and evict one cacheline.
    //============================================================================

    function void update_nru(bit [ADDR_WIDTH:0] ccpAddr,logic security, bit update_on_fill=0);
        int fq[$]; 
        int onesq[$]; 
        string spkt;
        int previous;
        int find_way[];
        bit allone_flag;
        longint iotag;
        int index;
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);
        iotag     = mapAddrToCCPTag(ccpAddr);

        if( ccpCacheSet.exists(index)) begin
            fq = ccpCacheSet[index].find_index() with (
                 (item.tag == iotag)         &&
                 (item.state != IX)          &&
                 (item.isPending == 0)       &&
                 (item.security == security)
                 ); 

            onesq = ccpCacheSet[index].find_index() with (
                 (item.isPending == 0)           
                 ); 

            if((fq.size() > 0) && (onesq.size()>0) && (update_on_fill == 0)) begin
                previous = nru_bit_q[index];
                nru_bit_q[index][fq[0]] = 1'b1;
                allone_flag = 1'b1;
                foreach(onesq[i]) begin
                    if(nru_bit_q[index][onesq[i]] == 1'b0)
                        allone_flag = 0;
                end
                if(allone_flag == 1'b1) begin
                    foreach(onesq[i]) begin
                        nru_bit_q[index][onesq[i]] = 1'b0;
                    end
                    
                    nru_bit_q[index][fq[0]] = 1'b1;

                    spkt = {"NRU bit for Addr:%h caused a flip to all 0's",
                           " Available ways to choose "};
                    foreach(onesq[i]) begin
                        spkt = {spkt, $sformatf("%0d,",onesq[i])}; 
                    end
                    `uvm_info("CCP_CACHE_MODEL",$psprintf(spkt, ccpAddr),UVM_MEDIUM) 
                end
                spkt = {"For Addr:%h, Index:%0h, Previous:%0b changed to Value:%b",
                        " Available ways to choose "};
                foreach(onesq[i]) begin
                    spkt = {spkt, $sformatf("%0d,",onesq[i])}; 
                end
                `uvm_info("NRU UPDATED",$psprintf(spkt,ccpAddr,index,previous,nru_bit_q[index]),UVM_MEDIUM) 
            end else if((fq.size() > 0) && (update_on_fill== 1'b1)) begin 
                previous = nru_bit_q[index];
                nru_bit_q[index][fq[0]] = 1'b1;

                spkt = {"For Addr:%h, Index:%0h, Previous:%0b changed to Value:%b",
                        " Available ways to choose "};
                foreach(onesq[i]) begin
                    spkt = {spkt, $sformatf("%0d,",onesq[i])}; 
                end
                `uvm_info("NRU UPDATED",$psprintf(spkt,ccpAddr,index,previous,nru_bit_q[index]),UVM_MEDIUM) 
            end else begin 
                spkt = {"Sorry the cache line you asked for in update_nru doesn't",
                     "exists"};
                `uvm_fatal("CCP_CACHE_MODEL",spkt)
            end
        end else begin
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                     "exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction

    //============================================================================
    // Name    : evict_cacheline
    // Purpose : Perform the eviction algorithm and evicts a cacheline. 
    // 
    // 
    //============================================================================
    function evict_cacheline(input bit [ADDR_WIDTH:0] ccpAddr,bit evict,bit isWrTh,input [NO_OF_WAYS-1:0] busyway,input nru_cnt_t nru_counter,
                             output ccpCacheLine cacheLine);
        int fq[$]; 
        string spkt;
        bit found_index_q[$];
        bit [ADDR_WIDTH:0] addr;
        nru_cnt_t m_nru_cnt;
        bit found_all_ones;
        logic security;
        int index; 
        int onesq[$]; 
        
        //index =  ncoreConfigInfo::get_set_index(ccpAddr,agent_id);
        index =  CcpCalcIndex(ccpAddr);


        `uvm_info("CCP_CACHE_MODEL",$sformatf(" Evicting Cacheline from Index :0x%0h",index),UVM_MEDIUM); 
        if(ccpCacheSet.exists(index)) begin
            `uvm_info("CCP_CACHE_MODEL",$sformatf("Index :%0d exists",index),UVM_MEDIUM); 
            foreach(ccpCacheSet[index,i])begin
            `uvm_info("CCP_CACHE_MODEL",$sformatf("way :%0d nru_bit_q:%0d isPending :%0b addr:%0x state :%0s",i,nru_bit_q[index][i],ccpCacheSet[index][i].isPending,ccpCacheSet[index][i].addr,ccpCacheSet[index][i].state),UVM_MEDIUM); 
            end
            onesq = ccpCacheSet[index].find_index() with (
                 (item.isPending == 0)           
                 );
            <% if(obj.nWays>1){%>
            <% if(obj.RepPolicy === "NRU"){%>
            spkt = {"For Addr:%h, Index:%0h, NRU-Counter:%h NRU:%b"};
            `uvm_info("NRU STATUS",$psprintf(spkt,ccpAddr,index,nru_counter,nru_bit_q[index]),UVM_MEDIUM) 

            //Reset the Counter
               m_nru_cnt = nru_counter;
            //if(nru_counter == 0) begin
            //    m_nru_cnt = NO_OF_WAYS-1;
            //end else begin
            //    m_nru_cnt = (nru_counter-1'b1);
            //end
           
            //NF: Do we need this for loop?
            for(int i=0; i<NO_OF_WAYS;i++) begin
            //`uvm_info("CCP_CACHE_MODEL",$sformatf("way :%0d nru_bit_q:%0d isPending :%0b busyway:%0d",i,nru_bit_q[index][m_nru_cnt],ccpCacheSet[index][m_nru_cnt].isPending, busyway[m_nru_cnt]),UVM_MEDIUM); 
            `uvm_info("CCP_CACHE_MODEL",$sformatf("way :%0d",i,),UVM_MEDIUM); 
            `uvm_info("CCP_CACHE_MODEL",$sformatf("nru_bit_q:%0d",nru_bit_q[index][m_nru_cnt]),UVM_MEDIUM); 
            `uvm_info("CCP_CACHE_MODEL",$sformatf("isPending :%0b",ccpCacheSet[index][m_nru_cnt].isPending),UVM_MEDIUM); 
            `uvm_info("CCP_CACHE_MODEL",$sformatf("busyway:%0d",busyway[m_nru_cnt]),UVM_MEDIUM); 
                if(busyway[m_nru_cnt] == 0 ) begin  
                    if(ccpCacheSet[index][m_nru_cnt].isPending==0) begin
                        cacheLine = new;
                        cacheLine.copy(ccpCacheSet[index][m_nru_cnt]);
                        addr = ccpCacheSet[index][m_nru_cnt].addr; 
                        security = ccpCacheSet[index][m_nru_cnt].security; 
                        if(evict) begin
                         delete_cacheline(addr,security);
                        end
                        found_index_q = {};
                        found_all_ones = 1;
                        break;
                    end
                end
                if(m_nru_cnt == 0) begin
                    m_nru_cnt = NO_OF_WAYS-1;
                end else begin
                    m_nru_cnt = m_nru_cnt - 1'b1;
                end
            end
           <% } %> 
            //Reset the Counter
               m_nru_cnt = nru_counter;
            //if(nru_counter == 0) begin
            //    m_nru_cnt = NO_OF_WAYS-1;
            //end else begin
            //    m_nru_cnt = (nru_counter-1'b1);
            //end

            if(found_all_ones == 0) begin
            <% if(obj.RepPolicy === "NRU"){%>
                spkt = {" All NRU bits are set to 1 for Index:%0h"};
                `uvm_info("CCP_CACHE_MODEL",$psprintf(spkt,ccpAddr),UVM_MEDIUM)

                spkt = {"For Addr:%h, Index:%0h, Value:%b Count:%0h",
                            " Available ways to choose "};
                foreach(onesq[i]) begin
                    spkt = {spkt, $sformatf("%0d,",onesq[i])}; 
                end
                `uvm_info("NRU WAYS AVAIL",$psprintf(spkt,ccpAddr,index,nru_bit_q[index],m_nru_cnt),UVM_MEDIUM)
           <% } else { %> 
            spkt = {"For Addr:%h, Index:%0h, NRU-Counter:%0d, m_nru_cnt:%0d NRU:%b"};
            `uvm_info("NRU STATUS",$psprintf(spkt,ccpAddr,index,nru_counter,m_nru_cnt,nru_bit_q[index]),UVM_MEDIUM) 
           <% } %> 
               //NF: Do we need this for loop? 
                for(int i=0; i<NO_OF_WAYS;i++) begin
            `uvm_info("CCP_CACHE_MODEL",$sformatf("way :%0d nru_bit_q:%0d isPending :%0b busyway:%0d",i,nru_bit_q[index][m_nru_cnt],ccpCacheSet[index][m_nru_cnt].isPending, busyway[m_nru_cnt]),UVM_MEDIUM); 
                  if(busyway[m_nru_cnt] == 0 ) begin  
                    if(ccpCacheSet[index][m_nru_cnt].isPending==0) begin
                        cacheLine = new;
                        cacheLine.copy(ccpCacheSet[index][m_nru_cnt]);
                        addr = ccpCacheSet[index][m_nru_cnt].addr; 
                        security = ccpCacheSet[index][m_nru_cnt].security; 
                        if(evict) begin
                         delete_cacheline(addr,security);
                        end
                        found_index_q = {};
                        break;
                     end
                  end
                    if(m_nru_cnt == 0) begin
                        m_nru_cnt = NO_OF_WAYS-1;
                    end else begin
                        m_nru_cnt = m_nru_cnt - 1'b1;
                    end
               end
            end
            <%}else{%>

            `uvm_info("CCP_CACHE_MODEL",$sformatf("onesq.size() :%0d",onesq.size()),UVM_MEDIUM);
            if(onesq.size()>0) begin
                cacheLine = new;
                cacheLine.copy(ccpCacheSet[index][0]);
                addr = ccpCacheSet[index][0].addr; 
                security = ccpCacheSet[index][0].security; 
                if(evict)begin
                 delete_cacheline(addr,security);
                end
            end

            <%}%>
        end else begin
            spkt = {"You are having a tough day. Sorry the cache index you asked for doesn't",
                     "exists"};
            `uvm_fatal("CCP_CACHE_MODEL",spkt)
        end
    endfunction
   
    //============================================================================
    // Name    : print_cache_model
    // Purpose : Prints the entire cacheline in a tabular format. Neat .... :) 
    // 
    // 
    //============================================================================
    function print_cache_model();
        foreach (ccpCacheSet[i]) begin 
            for(int m=0; m< ccpCacheSet[i].size();m++) begin
                //if(ccpCacheSet[i][m].state != IX)
                    ccpCacheSet[i][m].print(uvm_default_table_printer);
            end
        end
    endfunction

    //============================================================================
    // Name    : print_config_params
    // Purpose : Prints all the parameter used to generate the cache model.
    //           This will be useful for debugging things fast.
    // 
    //============================================================================
    function print_config_params();
        string spkt; 
        spkt = {"\n========================================================\n",
                " IO-$ Model Build Parameters\n",
                "========================================================\n",
                " ADDR_WIDTH:%0d\n DATA_WIDTH:%0d\n NO_OF_SETS:%0d\n ", 
                "NO_OF_WAYS:%0d\n INDEX_LOW:%0d\n INDEX_HIGH:%0d\n ", 
                "INDEX_SIZE:%0d\n BURSTLN:%0d\n"};
    
        `uvm_info("CCP_CACHE_MODEL",$psprintf(spkt,ADDR_WIDTH,DATA_WIDTH,NO_OF_SETS,
                 NO_OF_WAYS,INDEX_LOW, INDEX_HI, INDEX_SIZE,BURSTLN),
                 UVM_MEDIUM)
    endfunction

    
    //============================================================================
    // Name    : print_nru_bits
    // Purpose : Print NRU bits to check the status 
    // 
    // 
    //============================================================================
    function print_nru();
        foreach (nru_bit_q[i]) begin 
            `uvm_info("NRU-UPDATED", $psprintf("INDEX:%0h, NRU_BITS:%0b,",  
                    i, nru_bit_q[i]),UVM_MEDIUM)
        end
    endfunction
    
    
    //============================================================================
    // Name    : run_qa
    // Purpose : Code to test the above code :)
    // 
    //============================================================================
    function run_qa();
        bit chk;
        string sprint_pkt; 
        typedef bit [WCCPDATA-1:0] data_t[];
        data_t m_data;
        static int cnt=0;

        if(cnt==0) begin 

            chk=isCacheLineValid(.ccpAddr('h1000),.security(0));
            if(chk==1)
                //give_data(.ccpAddr('h1000), .ioData(m_data),.security(0));
            sprint_pkt = ""; 
            for(int i = 0; i < m_data.size(); i++) begin
                sprint_pkt = {sprint_pkt, $sformatf(" Data%0d:0x%0x"
                , i, m_data[i])};
            end
            cnt++;
            `uvm_info("CCP_CACHE_MODEL", $psprintf("%0s",sprint_pkt),UVM_MEDIUM)
        
            //Modify testing 
            modify_state(.ccpAddr('h1000), .ccpState(UD), .security(0));
            modify_state(.ccpAddr('h2000), .ccpState(SC), .security(0));
            modify_state(.ccpAddr('h3000), .ccpState(SC), .security(0));
            modify_state(.ccpAddr('h4000), .ccpState(UD), .security(0));
   
            //Delete Cacheline
            delete_cacheline(.ccpAddr('h5040), .security(0));
        
            //Full Testing 
            chk=isCacheIndexFull(.ccpAddr('h1000));
            if(chk)
                `uvm_info("CCP_CACHE_MODEL", "------PASSED------",UVM_MEDIUM)
            else 
                `uvm_error("CCP_CACHE_MODEL", "-------Failed-----" )

            chk=isCacheIndexFull(.ccpAddr('h6040));
            if(!chk)
                `uvm_info("CCP_CACHE_MODEL", "------PASSED------",UVM_MEDIUM)
            else 
                `uvm_error("CCP_CACHE_MODEL", "-------Failed-----" )
        
            //Print Model
            print_cache_model();
        end

    endfunction


    //============================================================================
    // Name    : gen_dummy_cache
    // Purpose : Function to geneate cache with known values
    // 
    //============================================================================
    function gen_dummy_cache();
        ccpCacheLine temp;
        int cnt;
        string spkt;
        
        for(int i=0; i<3; i++) begin 
            for(int j=0; j<NO_OF_WAYS;j++) begin 
                temp              = new;
                temp.addr         = ('h1000+('h40*i)) + ('h1000*cnt);
                randomize_data();
                temp.data         = new[m_data.size()];
                temp.data         = m_data;
                temp.state        = SC;
                temp.security     = 0;
                
                if(!(isCacheIndexValid(temp.addr)))
                    initCacheIndex(temp.addr); 
                add_cacheline(temp.addr,temp.state, 0,0,j);
                //modify_data(temp.addr,temp.data,0);
                temp.print();  
                cnt++;
            end
        end
    endfunction
    
    function void randomize_data();
        m_data = new[BURSTLN];
        for (int i = 0; i < m_data.size(); i++) begin
            ccp_ctrlwr_data_t   tmp;
            assert(std::randomize(tmp));
            m_data[i] = tmp;
            if (m_data[i] == '0) begin
                `uvm_error(get_name(), $sformatf("Data Randomization of ace cache line failed"));
            end
        end
    endfunction: randomize_data


endclass




//-------------------------------------
//Base class for generating Cachelines
// Let the I be capital for index
// since index is treated a function
// and it causes issue while using 
// find_index
//-------------------------------------
class ccpCacheLine extends uvm_object;

    ccp_ctrlop_addr_t      addr;
    ccp_ctrlwr_data_t      data[];
    bit                    dataErrorPerBeat[];
    ccp_cachestate_enum_t  state=IX;
    logic                  security;
    bit                    isPending;
    bit                    isHitupgrade;
    bit                    isInvldPending;
    int                    Index;
    int                    way;
    longint                tag;
    time                   t_creation;
    time                   t_last_update;

    `uvm_object_utils_begin  ( ccpCacheLine )
        `uvm_field_int       ( addr                  , UVM_DEFAULT       )
        `uvm_field_enum      ( ccp_cachestate_enum_t , state             , UVM_DEFAULT )
        `uvm_field_int       ( isPending             , UVM_DEFAULT       )
        `uvm_field_int       ( isHitupgrade          , UVM_DEFAULT       )
        `uvm_field_int       ( isInvldPending        , UVM_DEFAULT       )
        `uvm_field_int       ( Index                 , UVM_DEFAULT       )
        `uvm_field_int       ( way                   , UVM_DEFAULT       )
        `uvm_field_int       ( security              , UVM_DEFAULT       )
        `uvm_field_int       ( tag                   , UVM_DEFAULT       )
        `uvm_field_int       ( t_creation            , UVM_DEFAULT | UVM_TIME     )
        `uvm_field_int       ( t_last_update         , UVM_DEFAULT | UVM_TIME     )
        `uvm_field_array_int ( data                  , UVM_DEFAULT       )
        `uvm_field_array_int ( dataErrorPerBeat      , UVM_DEFAULT       )
    `uvm_object_utils_end

 
    // Constructor
    function new(string name = "ccpCacheLine");
        super.new(name);
    endfunction

    
    //Print Function  
    function string sprint_pkt();
        string spkt;
        spkt = {"Addr:0x%0x State:%s Index:%0h Tag:%0h isPending:%0h isHitupgrade :%0h ",
                "Security:%0h, Way:%0h"};
        sprint_pkt = $sformatf(spkt,addr,state,Index,tag,isPending,isHitupgrade,security,way);
        
         if(dataErrorPerBeat.size() > 0) begin
            for (int i = 0; i < dataErrorPerBeat.size(); i++) begin
                sprint_pkt = {sprint_pkt, $sformatf(" DataErrorPerBeat-%0d:0x%0x"
                ,i, dataErrorPerBeat[i])};
            end
        end else begin
            sprint_pkt = {sprint_pkt, " DataErrorPerBeat-0:0x0"};
        end

        if(data.size() > 0) begin
            for (int i = 0; i < data.size(); i++) begin
                sprint_pkt = {sprint_pkt, $sformatf(" Data%0d:0x%0x"
                ,i, data[i])};
            end
        end else begin
            sprint_pkt = {sprint_pkt, " Data0:0x0"};
        end
    endfunction : sprint_pkt

endclass: ccpCacheLine 


