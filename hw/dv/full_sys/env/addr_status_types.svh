

typedef bit [((2 ** <%=obj.wCacheLineOffset%>)*8)-1:0]  cache_data_t;
typedef bit [((2 ** <%=obj.wCacheLineOffset%>)-1):0]    cache_byte_en_t;

//TODO: Do we have a cache state width parameter?
typedef enum bit[2:0] {
					IX = 3'h0,
					SC = 3'h1,
					SD = 3'h2,
					UC = 3'h3,
					UD = 3'h4   
} cache_state_t;

typedef enum bit[2:0] {
					CMPDATARESP_IX   = 3'h0,
					CMPDATARESP_SC   = 3'h1,
					CMPDATARESP_UC   = 3'h2,
					CMPDATARESP_UDPD = 3'h6,
					CMPDATARESP_SDPD = 3'h7   
} chi_cmpdata_resp_t;

typedef enum bit[2:0] {
					SNPRESP_IX   = 3'h0,
					SNPRESP_SC   = 3'h1,
					SNPRESP_UC   = 3'h2,
					SNPRESP_SD   = 3'h3,
					SNPRESP_IXPD = 3'h4,
					SNPRESP_SCPD = 3'h5,
					SNPRESP_UCPD = 3'h6   
} chi_snp_resp_t;

typedef struct {
   cache_data_t      data;
   cache_byte_en_t   byte_en;
   int               funit_id;
   bit [2:0]         core_id;
   int               txn_id;
   bit               ns;
   bit               coh;
   bit               seen_at_slv_if;
   bit               cached;
   bit               snooped;
} outstanding_data_s;

typedef struct {
   cache_data_t      data;
   cache_byte_en_t   byte_en;
   bit[64:0]         addr;
   bit               cached;
} read_data_s;

typedef enum bit {
   MEMORY   = 1'b0,
   NCORE    = 1'b1
} cacheline_location_t;

typedef cache_state_t  cache_dir_state_t[<%=obj.nAIUs%>];
typedef bit [64:0] cache_dir_addr_t;

typedef enum bit[3:0] {ACE_READ_ONCE               = 4'b0000,
                       ACE_READ_SHARED             = 4'b0001,
                       ACE_READ_CLEAN              = 4'b0010,
                       ACE_READ_NOT_SHARED_DIRTY   = 4'b0011,
                       ACE_READ_UNIQUE             = 4'b0111,
                       ACE_CLEAN_SHARED            = 4'b1000,
                       ACE_CLEAN_INVALID           = 4'b1001,
                       ACE_MAKE_INVALID            = 4'b1101,
                       ACE_DVM_CMPL                = 4'b1110,
                       ACE_DVM_MSG                 = 4'b1111
                        } axi_acsnoop_enum_t;
