
class chi_dvm_addr_data_t extends uvm_object;
    rand addr_width_t m_addr;
    int k_dvm_tlbi_pct;
    int k_dvm_bpi_pct;
    int k_dvm_pici_pct;
    int k_dvm_vici_pct;
    int k_dvm_sync_pct;
    local bit m_set_knobs;
    local bit sent_dvm_sync;

    constraint c_part_num {
        //Table 8-4 CHI spec
        //Part Num, must be 0 for request
        m_addr[3:3] == 1'b0;
        //Security
        //00: Secure and non secure both
        //01: Reserved
        //10: Secure
        //11: Non-secure
        m_addr[8:7] inside {2'b00, 2'b10, 2'b11}; 
        //addr[10:9] Exception Level
        //00: Hypervisor and all gues OS
        //01: EL3
        //10: Gues OS
        //11: Hypervisor

        //Addr[13:11] DVMOp Type
        //000: TLBI
        //001: BPI
        //010: PICI
        //011: VICI
        //100: Sync
        //101-111: RSVD
        m_addr[13:11] dist {
            3'b000  := k_dvm_tlbi_pct,
            3'b001  := k_dvm_bpi_pct,
            3'b010  := k_dvm_pici_pct,
            3'b011  := k_dvm_vici_pct,
            3'b100  := k_dvm_sync_pct
        };
    }

  function new(string s = "chi_req_size_t");
    super.new(s);
    sent_dvm_sync = 0;
  endfunction: new

  function void set_dvm_knobs(int dvm_tlbi_pct,
                              int dvm_bpi_pct,
                              int dvm_pici_pct,
                              int dvm_vici_pct,
                              int dvm_sync_pct);
    k_dvm_tlbi_pct = dvm_tlbi_pct;
    k_dvm_bpi_pct  = dvm_bpi_pct;
    k_dvm_pici_pct = dvm_pici_pct;
    k_dvm_vici_pct = dvm_vici_pct;
    k_dvm_sync_pct = dvm_sync_pct;
    m_set_knobs = 1;
  endfunction: set_dvm_knobs

  function void pre_randomize();
    `ASSERT(m_set_knobs);
  endfunction: pre_randomize

  function void post_randomize();
    m_set_knobs = 0;
    if($test$plusargs("dvm_hang_test")) begin
        if (sent_dvm_sync==0) begin
	   m_addr[13:11] = 3'b100;
           sent_dvm_sync = 1;
	end else begin
	   m_addr[13:11] = 3'b000;
        end
    end	   
  endfunction: post_randomize

endclass : chi_dvm_addr_data_t

class chi_req_size_t extends uvm_object;

  `uvm_object_param_utils(chi_req_size_t)
  typedef int intq[$];

  rand int         m_size;
  chi_bfm_opcode_t m_req_opcode;
  rand bit [5:0]   m_starting_byte;
  local bit        m_set_req;
  int 		   perf_test;
   
  constraint c_req_size {
    if (
      m_req_opcode == BFM_ATOMICSTORE_STADD    || 
      m_req_opcode == BFM_ATOMICSTORE_STCLR    || 
      m_req_opcode == BFM_ATOMICSTORE_STEOR    || 
      m_req_opcode == BFM_ATOMICSTORE_STSET    || 
      m_req_opcode == BFM_ATOMICSTORE_STSMAX   || 
      m_req_opcode == BFM_ATOMICSTORE_STMIN    || 
      m_req_opcode == BFM_ATOMICSTORE_STUSMAX  ||
      m_req_opcode == BFM_ATOMICSTORE_STUMIN   || 
      m_req_opcode == BFM_ATOMICLOAD_LDADD     || 
      m_req_opcode == BFM_ATOMICLOAD_LDCLR     || 
      m_req_opcode == BFM_ATOMICLOAD_LDEOR     || 
      m_req_opcode == BFM_ATOMICLOAD_LDSET     || 
      m_req_opcode == BFM_ATOMICLOAD_LDSMAX    || 
      m_req_opcode == BFM_ATOMICLOAD_LDMIN     || 
      m_req_opcode == BFM_ATOMICLOAD_LDUSMAX   || 
      m_req_opcode == BFM_ATOMICLOAD_LDUMIN    || 
      m_req_opcode == BFM_ATOMICSWAP) {

      //CHI Spec, Ch 2.10.5 Pg 103 
      //CHI Spec, Ch 4.2 Pg 127
      m_size inside {[0:3]};

    } else if (m_req_opcode == BFM_ATOMICCOMPARE) {
      
      //CHI Spec, Ch 2.10.5 Pg 103 
      m_size inside {[1:5]};
    } else if (m_req_opcode == BFM_DVMOP) {
      //CHI Spec, Ch 8.1.4 Pg 237 
      m_size == 3;
    } else if (perf_test == 1) {
      m_size == 6;  // 64B access for performance test		        
    } else if (
      m_req_opcode == BFM_READNOSNP            ||
     /* m_req_opcode == BFM_WRITECLEANPTL      ||*/
      m_req_opcode == BFM_WRITENOSNPPTL        ||
      m_req_opcode == BFM_WRITEUNIQUEPTL || m_req_opcode == BFM_REQLCRDRETURN || m_req_opcode == BFM_PREFETCHTARGET   /*     ||
      m_req_opcode == BFM_WRITEBACKPTL*/) {

      //CHI Spec, Ch 2.10.2 Pg 100
      //CHI Spec, Ch 4.2 Pg 127
      //m_size inside {[0:6]};
      m_size dist {[0:4] := 25,[5:6] := 50};
    } else {
      m_size == 6;
    }
  }

<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
`ifdef VCS
 intq m_size_1 ;
 intq m_size_2 ;
`endif // `ifndef VCS ... `else ... 
 <% } %>
  constraint c_starting_byte {
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
`ifndef VCS
    if (m_req_opcode == BFM_ATOMICCOMPARE) 
      m_starting_byte inside {posb_values(m_size - 1)};
    else
      m_starting_byte inside {posb_values(m_size)};
`else // `ifndef VCS
    if (m_req_opcode == BFM_ATOMICCOMPARE){ 
       
      m_starting_byte inside {m_size_1};}
    else {
      m_starting_byte inside {m_size_2};}
`endif // `ifndef VCS ... `else ... 
 <% } else {%>
    if (m_req_opcode == BFM_ATOMICCOMPARE) 
      m_starting_byte inside {posb_values(m_size - 1)};
    else
      m_starting_byte inside {posb_values(m_size)};
 <% } %>
  }

  function new(string s = "chi_req_size_t");
    super.new(s);
    if($test$plusargs("perf_test")) begin
       perf_test = 1;
    end else begin
       perf_test = 0;
    end
  endfunction: new

  function void set_req_fields(chi_bfm_opcode_t opcode);
    m_req_opcode = opcode;
    m_set_req = 1;
  endfunction: set_req_fields

  function void pre_randomize();
    `ASSERT(m_set_req);
<% if(obj.testBench == 'chi_aiu'|| (obj.testBench == "fsys")) { %>
   `ifdef VCS
    if (m_req_opcode == BFM_ATOMICCOMPARE)begin 
    if(!m_size==0)
    m_size_1={posb_values(m_size - 1)};
    else
    m_size_1={posb_values(m_size)};
    end
    else begin  
    m_size_2={posb_values(m_size)}; 
    end
   `endif // `ifndef VCS ... `else ... 
 <% } %>
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

  function intq posb_values(int size);
    bit flag;
    int cnt;
    intq vq;

    cnt = 0;
    while (!flag) begin
      vq.push_back(cnt << size);
      ++cnt;
      if (cnt << size > 63) //Upperlimit is Cacheline Block size in bytes - 1
        flag = 1;
    end
    return vq;
  endfunction: posb_values

endclass: chi_req_size_t

class chi_req_ns extends uvm_object;

  `uvm_object_param_utils(chi_req_ns)

  rand bit m_ns;
  chi_bfm_opcode_t        m_opcode;
  chi_bfm_opcode_type_t m_opcode_type;
  local bit m_set_req;
  local bit non_secure_access_test;

  
       constraint c_ns {
         if (m_opcode == BFM_DVMOP) {
             m_ns == 0;
         }
         else {
              m_ns inside {0, 1};
         }
      }


  function void set_req_fields(chi_bfm_opcode_t opcode);
    m_opcode = opcode;
    m_set_req = 1; 
  endfunction: set_req_fields

  function void pre_randomize();
    `ASSERT(m_set_req); 
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

  function new(string s = "chi_req_ns");
    super.new(s);
    if($test$plusargs("non_secure_access_test")) begin
            non_secure_access_test = 1;
    end
  endfunction: new


endclass: chi_req_ns

class chi_req_compack_t extends uvm_object;
  
  `uvm_object_param_utils(chi_req_compack_t)
  
  rand bit m_expcompack;
  chi_bfm_opcode_t        m_opcode;
  chi_bfm_opcode_type_t m_opcode_type;
  local bit m_set_req;

  constraint c_compack {
    if (
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        (m_opcode_type == DT_LS_CMO_CMD && (m_opcode != BFM_CLEANSHARED) && (m_opcode != BFM_CLEANINVALID) && (m_opcode != BFM_MAKEINVALID)) ||
       <% } else { %>
        m_opcode_type == DT_LS_CMO_CMD ||
       <% } %>
        m_opcode_type == DT_LS_STH_CMD ||
       (m_opcode_type == DT_LS_UPD_CMD && m_opcode == BFM_EVICT) ||
        m_opcode_type == WR_NONCOH_CMD ||
        m_opcode_type == WR_STHUNQ_CMD ||
        m_opcode_type == WR_CPYBCK_CMD ||
        m_opcode_type == ATOMIC_ST_CMD ||
        m_opcode_type == ATOMIC_LD_CMD ||
        m_opcode_type == ATOMIC_SW_CMD ||
        m_opcode_type == ATOMIC_CM_CMD ||
        m_opcode_type == DVM_OPERT_CMD ||
        m_opcode_type == PRE_FETCH_CMD /* ||
        m_opcode_type == RQ_LCRDRT_CMD*/) {
      
      m_expcompack == 0;

    } else if ((m_opcode_type == RD_LDRSTR_CMD) ||
               (m_opcode_type == DT_LS_UPD_CMD && m_opcode != BFM_EVICT )) {
             
      m_expcompack == 1;

    } else {
      m_expcompack inside {0, 1};
    }
  }

  //Methods
  function new(string s = "chi_req_compack_t");
    super.new(s);
  endfunction: new

  function void set_req_fields(chi_bfm_opcode_type_t opcode_type, chi_bfm_opcode_t opcode);
    m_opcode_type = opcode_type;
    m_opcode = opcode;
    m_set_req = 1; 
  endfunction: set_req_fields

  function void pre_randomize();
    `ASSERT(m_set_req); 
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

endclass: chi_req_compack_t

class chi_req_cacheable_alloc_t extends uvm_object;

  `uvm_object_param_utils(chi_req_cacheable_alloc_t)

  rand bit m_cacheable;
  rand bit m_alloc;

  chi_bfm_opcode_type_t   m_opcode_type;
  chi_bfm_opcode_t        m_opcode;
  chi_bfm_memory_target_t m_mem_type;
  local bit               m_set_req;
  local bit 		  force_cacheable = $test$plusargs("force_cacheable_txn") ? 1 : 0;
  local bit 		  force_allocate  = $test$plusargs("force_allocate_txn") ? 1 : 0;

  //CHI Spec Ch 2.9.3 Pg 94
  constraint c_cacheable {
    if (m_mem_type == DEVICE) {
       m_cacheable == 0;
    } else {
      (m_opcode_type == RD_RDONCE_CMD	 ||
       m_opcode_type == RD_LDRSTR_CMD	 ||
       m_opcode_type == DT_LS_UPD_CMD	 ||
       m_opcode_type == DT_LS_STH_CMD	 ||
       m_opcode_type == WR_COHUNQ_CMD	 ||
       m_opcode_type == WR_STHUNQ_CMD	 ||
       m_opcode_type == WR_CPYBCK_CMD	 ||
       m_opcode_type == DT_LS_STH_CMD	 ||
       m_opcode      == BFM_EVICT)   	-> 
	m_cacheable == 1;
      
      (m_opcode_type == RQ_LCRDRT_CMD	 ||
       m_opcode_type == PRE_FETCH_CMD    ||
       m_opcode_type == ATOMIC_LD_CMD	 ||
       m_opcode_type == ATOMIC_ST_CMD	 ||
       m_opcode_type == ATOMIC_SW_CMD	 ||
       m_opcode_type == ATOMIC_CM_CMD) 	->
	m_cacheable inside {0, 1};
 
      (m_opcode_type == DVM_OPERT_CMD)   ->
       m_cacheable == 0;

     (force_cacheable == 1 && !(m_opcode_type == DVM_OPERT_CMD)) -> m_cacheable inside {1};
    }
  }

  constraint cacheable_alloc { solve m_cacheable before m_alloc;};
  //CHI Spec Ch 2.9.3 Pg 94
  constraint c_allocate {
    if (m_mem_type == DEVICE ) {
       m_alloc == 0;
    } else {
    if((m_opcode_type  == RQ_LCRDRT_CMD           ||
       m_opcode_type  == PRE_FETCH_CMD           || 
       m_opcode_type  == ATOMIC_LD_CMD           ||
       m_opcode_type  == ATOMIC_ST_CMD           ||
       m_opcode_type  == ATOMIC_SW_CMD      	 ||

    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
       m_opcode       == BFM_WRITEEVICTFULL 	 ||  
    <% } %> 
       m_opcode_type  == ATOMIC_CM_CMD           ||
       m_opcode       == BFM_READNOSNP           ||
       m_opcode       == BFM_CLEANSHARED         ||
       m_opcode       == BFM_CLEANSHAREDPERSIST  ||
       m_opcode       == BFM_CLEANINVALID        ||
       m_opcode       == BFM_MAKEINVALID         ||
       m_opcode       == BFM_WRITENOSNPPTL       ||
       m_opcode       == BFM_WRITENOSNPFULL) && ( m_cacheable == 1)) {
   
	m_alloc inside {0,1}; 
      }else if((m_opcode_type  == RQ_LCRDRT_CMD   ||
       m_opcode_type  == PRE_FETCH_CMD           || 
       m_opcode_type  == ATOMIC_LD_CMD           ||
       m_opcode_type  == ATOMIC_ST_CMD           ||
       m_opcode_type  == ATOMIC_SW_CMD      	 ||

    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
       m_opcode       == BFM_WRITEEVICTFULL 	 ||  
    <% } %> 
       m_opcode_type  == ATOMIC_CM_CMD           ||
       m_opcode       == BFM_READNOSNP           ||
       m_opcode       == BFM_CLEANSHARED         ||
       m_opcode       == BFM_CLEANSHAREDPERSIST  ||
       m_opcode       == BFM_CLEANINVALID        ||
       m_opcode       == BFM_MAKEINVALID         ||
       m_opcode       == BFM_WRITENOSNPPTL       ||
       m_opcode       == BFM_WRITENOSNPFULL) && ( m_cacheable == 0)) { 
       	
       m_alloc == 0;
       }
      (m_opcode       == BFM_EVICT 		 ||
       m_opcode       == BFM_READONCEMAKEINVALID ||
       m_opcode_type  == DVM_OPERT_CMD ) ->

	m_alloc == 0; 

 <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
       (m_opcode       == BFM_WRITEEVICTFULL) -> m_alloc == 1;
  <% } %> 

      (force_allocate == 1 && (!(m_opcode       == BFM_EVICT 		 ||
       m_opcode       == BFM_READONCEMAKEINVALID ||
       m_opcode_type  == DVM_OPERT_CMD ))) -> m_alloc inside {1};
    }
  }

  //Methods
  function new(string s = "chi_req_cacheable_alloc_t");
    super.new(s);
  endfunction: new

  function void set_req_fields(
    chi_bfm_opcode_t        opcode,
    chi_bfm_opcode_type_t   opcode_type,
    chi_bfm_memory_target_t memory_type);

    m_opcode        = opcode;
    m_opcode_type   = opcode_type;
    m_mem_type      = memory_type; 
    m_set_req       = 1;
  endfunction: set_req_fields

  function void pre_randomize();
    `ASSERT(m_set_req);
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

endclass: chi_req_cacheable_alloc_t

class chi_req_likelyshared_t extends uvm_object;

  `uvm_object_param_utils(chi_req_likelyshared_t)

  rand bit m_likelyshared;
  chi_bfm_opcode_t m_opcode;
  local bit m_set_req;

  //CHI Spec Ch 2.9.5 Pg 97
  constraint c_likelyshared {
     if ((m_opcode == BFM_READCLEAN           )	 || 
       	( m_opcode == BFM_READNOTSHAREDDIRTY  )	 || 
       	( m_opcode == BFM_PREFETCHTARGET      )	 || 
       	( m_opcode == BFM_STASHONCESHARED     )	 || 
       	( m_opcode == BFM_WRITEUNIQUEPTLSTASH )	 || 
       	( m_opcode == BFM_WRITEUNIQUEFULLSTASH)	 || 
       	( m_opcode == BFM_WRITECLEANFULL      )	 || 
       	( m_opcode == BFM_READSHARED          )	 ||
       	( m_opcode == BFM_STASHONCEUNIQUE     )	 ||
        ( m_opcode == BFM_REQLCRDRETURN	      )  ||
       	( m_opcode == BFM_WRITEUNIQUEPTL      )	 ||
       	( m_opcode == BFM_WRITEUNIQUEFULL     )	 ||
       	( m_opcode == BFM_WRITEBACKFULL       )	 ||
       	( m_opcode == BFM_WRITEEVICTFULL))  
 
        m_likelyshared inside {0,1};

    else
        m_likelyshared == 0;
  }

  //Methods
  function new(string s = "chi_req_likelyshared_t");
    super.new(s);
  endfunction: new

  function void set_req_fields(chi_bfm_opcode_t opcode);
    m_opcode  = opcode;
    m_set_req = 1; 
  endfunction: set_req_fields

  function void pre_randomize();
    `ASSERT(m_set_req);
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

endclass: chi_req_likelyshared_t

class chi_req_stashnid_t extends uvm_object;

  `uvm_object_param_utils(chi_req_stashnid_t)

  bit m_stashnid;
  chi_bfm_opcode_t m_opcode;
  chi_bfm_opcode_type_t   m_opcode_type;
  bit m_set_req;
  int temp = <%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.SrcID%>;

 constraint c_m_stashnid {
    if ((m_opcode_type == DVM_OPERT_CMD) 	||   
	(m_opcode_type == RQ_LCRDRT_CMD) 	||  	
	(m_opcode_type == RD_NONCOH_CMD) 	||  	
	(m_opcode_type == RD_LDRSTR_CMD) 	||  	
	(m_opcode_type == RD_RDONCE_CMD)	||
 	(m_opcode_type == DT_LS_CMO_CMD)	||
	(m_opcode_type == DT_LS_UPD_CMD)	||
 	(m_opcode_type == WR_CPYBCK_CMD)	||
	(m_opcode_type == WR_COHUNQ_CMD)	||
	(m_opcode_type == PRE_FETCH_CMD)	||
	(m_opcode_type == WR_NONCOH_CMD)	||
	(m_opcode_type == ATOMIC_ST_CMD)	||
	(m_opcode_type == ATOMIC_LD_CMD)	||
	(m_opcode_type == ATOMIC_SW_CMD)	||
	(m_opcode_type == ATOMIC_CM_CMD))	{
        	m_stashnid == 0;
    }
else {
 	((m_opcode_type == DT_LS_STH_CMD)|| (m_opcode_type == RQ_LCRDRT_CMD))  ->
        	m_stashnid inside {0,2^temp};
    }
}

 function new(string s = "chi_req_stashnid_t");
    super.new(s);
  endfunction: new
 
  function void set_req_fields(chi_bfm_opcode_type_t opcode_type, chi_bfm_opcode_t opcode);
    m_opcode  = opcode;
    m_opcode_type = opcode_type;
    m_set_req = 1;
  endfunction: set_req_fields

  function void pre_randomize();
    m_set_req = 1;
    `ASSERT(m_set_req);
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

endclass: chi_req_stashnid_t

class chi_req_allowretry_t extends uvm_object;

  `uvm_object_param_utils (chi_req_allowretry_t)

  rand bit m_allowretry;
  bit allow_retry_rand;
  chi_bfm_opcode_t m_opcode;
  chi_bfm_opcode_type_t   m_opcode_type;
  bit m_set_req;

 constraint c_allowretry {
   if (allow_retry_rand &&
      (( <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>

        (m_opcode_type == ATOMIC_ST_CMD) 	    	||
        (m_opcode_type == ATOMIC_LD_CMD) 	   	||
        (m_opcode_type == ATOMIC_SW_CMD) 	    	||
        (m_opcode_type == ATOMIC_CM_CMD) 	    	||
	(m_opcode == BFM_STASHONCESHARED) 	    	||
 	(m_opcode == BFM_STASHONCEUNIQUE) 	    	||
	(m_opcode == BFM_READONCEMAKEINVALID) 	    	||
	(m_opcode == BFM_READONCECLEANINVALID) 	    	||
	(m_opcode == BFM_CLEANSHAREDPERSIST) 	    	||

        <% } else { %>
	(m_opcode == BFM_WRITECLEANPTL) 	    	||
	<% } %>

	(m_opcode == BFM_DVMOP)				||   
	(m_opcode == BFM_READSHARED)			||  	
	(m_opcode == BFM_READCLEAN)			||
	(m_opcode == BFM_READONCE)			||
	(m_opcode == BFM_READUNIQUE)			||
	(m_opcode == BFM_CLEANSHARED)			||
	(m_opcode == BFM_READNOSNP)			||
	(m_opcode == BFM_CLEANINVALID)			||
	(m_opcode == BFM_MAKEINVALID)			||	
	(m_opcode == BFM_CLEANUNIQUE)			||
	(m_opcode == BFM_MAKEUNIQUE)			||
	(m_opcode == BFM_EVICT)  			||
	(m_opcode == BFM_WRITECLEANFULL)		||
	(m_opcode == BFM_WRITEEVICTFULL)		||
	(m_opcode == BFM_WRITEBACKFULL)			||
	(m_opcode == BFM_WRITEBACKPTL)			||
	(m_opcode == BFM_WRITENOSNPFULL)   		||
	(m_opcode == BFM_WRITENOSNPPTL)   		||
	(m_opcode == BFM_WRITEUNIQUEFULL)		||
	(m_opcode == BFM_WRITEUNIQUEPTL	))))   	
 
         m_allowretry inside {0,1};

    else 
        m_allowretry == 0;
  }

 function new(string s = "chi_req_allowretry_t");
    super.new(s);
    if($test$plusargs("allow_retry_rand")) begin
        allow_retry_rand = 1;
    end	   
  endfunction: new
 
  function void set_req_fields(chi_bfm_opcode_type_t opcode_type, chi_bfm_opcode_t opcode);
    m_opcode_type = opcode_type;
    m_opcode  = opcode;
    m_set_req = 1;
  endfunction: set_req_fields

  function void pre_randomize();
    m_set_req = 1;
    `ASSERT(m_set_req);
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

endclass: chi_req_allowretry_t

class chi_req_order_t extends uvm_object;

  `uvm_object_param_utils(chi_req_order_t)

  //Properties
  rand chi_bfm_order_t m_order;

  chi_bfm_memory_target_t m_mem_type;
  chi_bfm_opcode_type_t   m_opcode_type;
  chi_bfm_opcode_t m_req_opcode;
  local bit m_set_req;

  constraint c_order {
    if ((m_mem_type == NORMAL) && 
        (m_opcode_type == RD_NONCOH_CMD ||
         m_opcode_type == WR_NONCOH_CMD))  {

       m_order inside {NO_ORDER, REQUEST_ORDER};
    } else if ((m_mem_type == NORMAL) && m_opcode_type == RD_RDONCE_CMD) {
       //m_order inside {REQUEST_ORDER, ENDPOINT_ORDER};
       m_order inside {NO_ORDER, REQUEST_ORDER, ENDPOINT_ORDER};
    } else if ((m_mem_type == NORMAL) && m_opcode_type == WR_COHUNQ_CMD) {
       //m_order inside {REQUEST_ORDER, ENDPOINT_ORDER};
       m_order inside {NO_ORDER, REQUEST_ORDER, ENDPOINT_ORDER};
    } else if ( m_opcode_type == ATOMIC_ST_CMD || m_opcode_type == ATOMIC_LD_CMD ||
         m_opcode_type == ATOMIC_SW_CMD || m_opcode_type == ATOMIC_CM_CMD){
       m_order inside {NO_ORDER, REQUEST_ORDER, ENDPOINT_ORDER};
    } else if (m_opcode_type == DT_LS_UPD_CMD) {
       m_order inside {NO_ORDER};
     //m_order inside {REQUEST_ORDER,ENDPOINT_ORDER}; //NEED ENDPOINT
    } else if ((m_mem_type == DEVICE) && (m_opcode_type == DT_LS_CMO_CMD)) {
       m_order == NO_ORDER;
    } else if (m_req_opcode == BFM_REQLCRDRETURN) {
       m_order inside {NO_ORDER, REQUEST_ORDER, ENDPOINT_ORDER};
    } else if (m_mem_type == DEVICE) {
       m_order inside {NO_ORDER, REQUEST_ORDER, ENDPOINT_ORDER};
    } else {
       m_order == NO_ORDER;
    }
  }

  //Methods
  function new(string s = "chi_req_likelyshared_t");
    super.new(s);
  endfunction: new

  function void set_req_fields(
    chi_bfm_opcode_type_t   opcode_type,
    chi_bfm_memory_target_t mem_type,
    chi_bfm_opcode_t opcode);

    m_opcode_type   = opcode_type;
    m_req_opcode   = opcode;
    m_mem_type = mem_type;
    m_set_req = 1;
  endfunction: set_req_fields

  function void pre_randomize();
    `ASSERT(m_set_req);
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

endclass: chi_req_order_t


class chi_req_excl_t extends uvm_object;

  `uvm_object_param_utils(chi_req_excl_t)

  rand bit m_excl;
  chi_bfm_opcode_t m_opcode;
  int m_excl_wgt;
  bit m_set_req;

  //CHI Spec Ch 2.9.5 Pg 97
  constraint c_excl {
    if (m_opcode == BFM_READCLEAN            || 
        m_opcode == BFM_READNOTSHAREDDIRTY   || 
        m_opcode == BFM_READSHARED           ||
        m_opcode == BFM_CLEANUNIQUE          ||
        m_opcode == BFM_READNOSNP            ||
        m_opcode == BFM_WRITENOSNPFULL       ||
        m_opcode == BFM_WRITENOSNPPTL        ||
        m_opcode == BFM_PREFETCHTARGET       ||
        m_opcode == BFM_REQLCRDRETURN){ 
 
        m_excl dist {
            1 := m_excl_wgt,
            0 := 100 - m_excl_wgt
        };
    }
    else
        m_excl == 0;
  }

  //Methods
  function new(string s = "chi_req_excl_t");
    super.new(s);
  endfunction: new

  function void set_req_fields(chi_bfm_opcode_t opcode, int excl_wgt);
    m_opcode  = opcode;
    m_excl_wgt = excl_wgt;
    m_set_req = 1;
  endfunction: set_req_fields

  function void pre_randomize();
    `ASSERT(m_set_req);
  endfunction: pre_randomize

  function void post_randomize();
    m_set_req = 0;
  endfunction: post_randomize

endclass: chi_req_excl_t
