//-------------------------------------------------------------------------------------------------- 
// AXI Parameters
//-------------------------------------------------------------------------------------------------- 

<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
// Change below to use WARID and WAWID
// This needs to be defined in build_tb_env
typedef bit [WARID-1:0] axi_arid_t;
typedef bit [WAWID-1:0] axi_awid_t;
<% } else { %>    
typedef bit [WAXID-1:0] axi_arid_t;
typedef bit [WAXID-1:0] axi_awid_t;
<% } %>
typedef bit [WAXADDR-1:0] axi_axaddr_t;
typedef bit [WAXADDR-1+<%=obj.wSecurityAttribute%>:0] axi_axaddr_security_t;
typedef bit [WXDATA-1:0] axi_xdata_t;
typedef bit [WXDATA/8-1:0] axi_xstrb_t;
typedef bit [WAWUSER-1:0] axi_awuser_t;
typedef bit [WARUSER-1:0] axi_aruser_t;
typedef bit [WWUSER-1:0] axi_wuser_t;
typedef bit [WRUSER-1:0] axi_ruser_t;
typedef bit [WBUSER-1:0] axi_buser_t;
typedef bit [WCDDATA-1:0] axi_cddata_t;

typedef bit [CAXLEN-1:0] axi_axlen_t;
typedef bit [CAXSIZE-1:0] axi_axsize_t;
typedef bit [CAXBURST-1:0] axi_axburst_t;
typedef bit [CAXLOCK-1:0] axi_axlock_t;
typedef bit [CAXCACHE-1:0] axi_axcache_t;
typedef bit [CAXPROT-1:0] axi_axprot_t;
typedef bit [CAXQOS-1:0] axi_axqos_t;
typedef bit [CAXREGION-1:0] axi_axregion_t;
typedef bit [CARSNOOP-1:0] axi_arsnoop_t;
typedef bit [CAWSNOOP-1:0] axi_awsnoop_t;
typedef bit [CACSNOOP-1:0] axi_acsnoop_t;
typedef bit [CAXDOMAIN-1:0] axi_axdomain_t;
typedef bit [CAXBAR-1:0] axi_axbar_t;
typedef bit [CRRESP-1:0] axi_rresp_t;
typedef bit [CBRESP-1:0] axi_bresp_t;
typedef bit [CCRRESP-1:0] axi_crresp_t;
parameter SYS_nSysCacheline   = <%=Math.pow(2, obj.DutInfo.wCacheLineOffset)%>;
parameter SYS_wSysCacheline   = <%=obj.DutInfo.wCacheLineOffset%>;
parameter BARRIER_AXID        = 2**(WAXID-1) - 1;
parameter DVM_ARID_1          = BARRIER_AXID - 1;
parameter DVM_ARID_2          = BARRIER_AXID - 2;
parameter DVM_ARID_3          = BARRIER_AXID - 3;
parameter WID_CHK                = <%=Math.ceil(obj.DutInfo.wAwId/8)%>;//  TODO-CONC-15634
parameter WRID_CHK               = <%=Math.ceil(obj.DutInfo.wArId/8)%>;  
parameter WAXADDR_CHK            = <%=Math.ceil(obj.DutInfo.wAddr/8)%>;  
parameter WASTRB_CHK            = WXDATA/64;
parameter WAWUSERCHK = (WAWUSER%8 !=0 )?((WAWUSER/8)+1'b1):(WAWUSER/8 ==0)?1:(WAWUSER/8); 
parameter WARUSERCHK = (WARUSER%8 !=0 )?((WARUSER/8)+1'b1):(WARUSER/8 == 0)?1:(WARUSER/8);
parameter WWUSERCHK = (WWUSER%8 !=0 )?((WWUSER/8)+1'b1):(WWUSER/8 == 0)?1:(WWUSER/8) ; 
parameter WRUSERCHK = (WRUSER%8 !=0 )?((WRUSER/8)+1'b1):(WRUSER/8 == 0)?1:(WRUSER/8) ; 
parameter WBUSERCHK = (WBUSER%8 !=0 )?((WBUSER/8)+1'b1):(WBUSER/8 == 0)?1:(WBUSER/8) ; 
<%if(obj.Block == "aiu" || obj.Block === 'io_aiu' || obj.Block === 'aceaiu') { %> 
// Change below to use WARID and WAWID
// This needs to be defined in build_tb_env
typedef logic [WARID-1:0] axi_arid_logic_t;
typedef logic [WAWID-1:0] axi_awid_logic_t;
<% } else { %>    
typedef logic [WAXID-1:0] axi_arid_logic_t;
typedef logic [WAXID-1:0] axi_awid_logic_t;
<% } %>
typedef logic [WID_CHK-1:0] axi_widchk_logic_t;
typedef logic [WRID_CHK-1:0] axi_ridchk_logic_t;
typedef logic [WAXADDR_CHK-1:0] axi_axaddrchk_logic_t;
typedef logic [WASTRB_CHK-1:0] axi_wstrbchk_logic_t;
typedef logic [WAXADDR-1:0] axi_axaddr_logic_t;
typedef logic [WXDATA-1:0] axi_xdata_logic_t;
typedef logic [WXDATA/8-1:0] axi_xstrb_logic_t;
typedef logic [WAWUSER-1:0] axi_awuser_logic_t;
typedef logic [WAWUSERCHK-1 :0] axi_awuserchk_logic_t;
typedef logic [WARUSER-1:0] axi_aruser_logic_t;
typedef logic [WARUSERCHK-1:0] axi_aruserchk_logic_t;
typedef logic [WWUSER-1:0] axi_wuser_logic_t;
typedef logic [WWUSERCHK-1:0] axi_wuserchk_logic_t;
typedef logic [WRUSER-1:0] axi_ruser_logic_t;
typedef logic [WRUSERCHK-1:0] axi_ruserchk_logic_t;
typedef logic [WBUSER-1:0] axi_buser_logic_t;
typedef logic [WBUSERCHK-1:0] axi_buserchk_logic_t;
typedef logic [WCDDATA-1:0] axi_cddata_logic_t;

typedef logic [CAXLEN-1:0] axi_axlen_logic_t;
typedef logic [CAXSIZE-1:0] axi_axsize_logic_t;
typedef logic [CAXBURST-1:0] axi_axburst_logic_t;
typedef logic [CAXLOCK-1:0] axi_axlock_logic_t;
typedef logic [CAXCACHE-1:0] axi_axcache_logic_t;
typedef logic [CAXPROT-1:0] axi_axprot_logic_t;
typedef logic [CAXQOS-1:0] axi_axqos_logic_t;
typedef logic [CAXREGION-1:0] axi_axregion_logic_t;
typedef logic [CARSNOOP-1:0] axi_arsnoop_logic_t;
typedef logic [CAWSNOOP-1:0] axi_awsnoop_logic_t;
typedef logic [CACSNOOP-1:0] axi_acsnoop_logic_t;
typedef logic [CAXDOMAIN-1:0] axi_axdomain_logic_t;
typedef logic [CAXBAR-1:0] axi_axbar_logic_t;
typedef logic [CRRESP-1:0] axi_rresp_logic_t;
typedef logic [CBRESP-1:0] axi_bresp_logic_t;
typedef logic [CCRRESP-1:0] axi_crresp_logic_t;

// AXI-LITE-E signal types
typedef logic [WAWATOP-1:0] axi_awatop_t;
typedef logic [WARVMIDEXT-1:0] axi_arvmidext_t;
typedef logic [WACVMIDEXT-1:0] axi_acvmidext_t;
typedef logic [WAWSTASHNID-1:0] axi_awstashnid_t;
typedef logic [WAWSTASHLPID-1:0] axi_awstashlpid_t;
typedef logic [WRPOISON-1:0] axi_rpoison_t;
typedef logic [WWPOISON-1:0] axi_wpoison_t;
typedef logic [WCDPOISON-1:0] axi_cdpoison_t;
typedef logic [WRDATACHK-1:0] axi_rdatachk_t;
typedef logic [WWDATACHK-1:0] axi_wdatachk_t;
typedef logic [WCDDATACHK-1:0] axi_cddatachk_t;
typedef logic [WARLOOP-1:0] axi_arloop_t;
typedef logic [WAWLOOP-1:0] axi_awloop_t;
typedef logic [WRLOOP-1:0] axi_rloop_t;
typedef logic [WBLOOP-1:0] axi_bloop_t;
typedef logic [WAXMMUSID-1:0] axi_axmmusid_t;
typedef logic [WAXMMUSSID-1:0] axi_axmmussid_t;
typedef logic [WARNSAID-1:0] axi_arnsaid_t;
typedef logic [WAWNSAID-1:0] axi_awnsaid_t;
typedef logic [WCRNSAID-1:0] axi_crnsaid_t;

typedef logic [WAWATOP-1:0] axi_awatop_logic_t;
typedef logic [WARVMIDEXT-1:0] axi_arvmidext_logic_t;
typedef logic [WACVMIDEXT-1:0] axi_acvmidext_logic_t;
typedef logic [WAWSTASHNID-1:0] axi_awstashnid_logic_t;
typedef logic [WAWSTASHLPID-1:0] axi_awstashlpid_logic_t;
typedef logic [WRPOISON-1:0] axi_rpoison_logic_t;
typedef logic [WWPOISON-1:0] axi_wpoison_logic_t;
typedef logic [WCDPOISON-1:0] axi_cdpoison_logic_t;
typedef logic [WXDATA/8-1:0] axi_rdatachk_logic_t;
typedef logic [WXDATA/8-1:0] axi_wdatachk_logic_t;
typedef logic [WCDDATACHK-1:0] axi_cddatachk_logic_t;
typedef logic [WARLOOP-1:0] axi_arloop_logic_t;
typedef logic [WAWLOOP-1:0] axi_awloop_logic_t;
typedef logic [WRLOOP-1:0] axi_rloop_logic_t;
typedef logic [WBLOOP-1:0] axi_bloop_logic_t;
typedef logic [WAXMMUSID-1:0] axi_axmmusid_logic_t;
typedef logic [WAXMMUSSID-1:0] axi_axmmussid_logic_t;
typedef logic [WARNSAID-1:0] axi_arnsaid_logic_t;
typedef logic [WAWNSAID-1:0] axi_awnsaid_logic_t;
typedef logic [WCRNSAID-1:0] axi_crnsaid_logic_t;
//--------------------------------------------------------------------------------------------------
// Enums Functions for ACE packets that have predefined types 
//-------------------------------------------------------------------------------------------------- 

typedef enum axi_axcache_t {RDEVNONBUF   = 4'b0000,
                            RDEVBUF      = 4'b0001,
                            RNORNCNONBUF = 4'b0010,
                            RNORNCBUF    = 4'b0011,
                            RWTRALLOC    = 4'b0110,
                            //RWTNALLOC    = 4'b1010,
                            //RWTRALLOC    = 4'b1110,
                            RWTWALLOC    = 4'b1010,
                            RWTRWALLOC   = 4'b1110,
                            //RWBNALLOC    = 4'b1011,
                            RWBRALLOC    = 4'b0111,
                            RWBWALLOC    = 4'b1011,
                            RWBRWALLOC   = 4'b1111
                           } axi_arcache_enum_t;

typedef enum axi_axcache_t {WDEVNONBUF   = 4'b0000,
                            WDEVBUF      = 4'b0001,
                            WNORNCNONBUF = 4'b0010,
                            WNORNCBUF    = 4'b0011,
                            WWTNALLOC    = 4'b0110,
                            //WWTRALLOC    = 4'b1110,
                            WWTWALLOC    = 4'b1010,
                            WWTRWALLOC   = 4'b1110,
                            //WWBNALLOC    = 4'b1011,
                            WWBRALLOC    = 4'b0111,
                            WWBWALLOC    = 4'b1011,
                            WWBRWALLOC   = 4'b1111
                           } axi_awcache_enum_t;

typedef enum axi_axdomain_t {NONSHRBL  = 2'b00,
                             INNRSHRBL = 2'b01,
                             OUTRSHRBL = 2'b10,
                             SYSTEM    = 2'b11
                            } axi_axdomain_enum_t; 

<% if (obj.testBench != "emu") { %>
typedef enum int {RDNOSNP,
                  RDONCE,
                  RDSHRD,
                  RDCLN,
                  RDNOTSHRDDIR,
                  RDUNQ,
                  CLNUNQ,
                  MKUNQ,
                  CLNSHRD,
                  CLNINVL,
                  MKINVL,
                  BARRIER,
                  DVMCMPL,
                  DVMMSG,
                  WRNOSNP,
                  WRUNQ,
                  WRLNUNQ,
                  WRCLN,
                  WRBK,
                  EVCT,
                  WREVCT,
		  ATMSTR,
		  ATMLD,
		  ATMSWAP,
		  ATMCOMPARE,
		  WRUNQPTLSTASH,
		  WRUNQFULLSTASH,
		  STASHONCESHARED,
		  STASHONCEUNQ,
		  STASHTRANS,
		  RDONCECLNINVLD,
		  RDONCEMAKEINVLD,
		  CLNSHRDPERSIST
              } ace_command_types_enum_t; 
<% } else { %>

typedef enum int {
                  
    RDNOSNP = 1,  
    RDONCE,        
    RDCLN,         
    RDNOTSHRDDIR,  
    RDSHRD,        
    RDUNQ,         
    CLNSHRD,       
    CLNINVL,       
    CLNUNQ,        
    MKUNQ,         
    MKINVL,        
    WRNOSNP,       
    WRUNQ,         
    WRLNUNQ,       
    WRCLN,         
    WRBK,          
    EVCT,          
    WREVCT,               
    BARRIER,       
    DVMCMPL,       
    DVMMSG,        
    ATMSTR,
    ATMLD,
    ATMSWAP,
    ATMCOMPARE,
    WRUNQPTLSTASH,
    WRUNQFULLSTASH,
    STASHONCESHARED,
    STASHONCEUNQ,
    STASHTRANS,
    RDONCECLNINVLD,
    RDONCEMAKEINVLD,
    CLNSHRDPERSIST


}  ace_command_types_enum_t;<% } %>

typedef enum int {ADD,
                  CLR,
		  EOR,
		  SET,
		  SMAX,
		  SMIN,
		  UMAX,
		  UMIN
              } awatop_types_enum_t;

typedef enum int {LTLEND,
                  BIGEND
              } endian_types_enum_t;

typedef enum axi_bresp_t {OKAY   = 2'b00,
                          EXOKAY = 2'b01,
                          SLVERR = 2'b10,
                          DECERR = 2'b11
                      } axi_bresp_enum_t;

// Other values of the 4 bit register are only used in AXI3
typedef enum axi_axlock_t {NORMAL = 1'b0,
                           EXCLUSIVE = 1'b1
                       } axi_axlock_enum_t; 

typedef enum axi_axburst_t {AXIFIXED = 2'b00,
                            AXIINCR  = 2'b01,
                            AXIWRAP  = 2'b10
                        } axi_axburst_enum_t;

typedef enum axi_axbar_t {NORMALBAR   = 2'b00,
                          MEMORYBAR   = 2'b01,
                          NORMALNOBAR = 2'b10,
                          SYNCBAR     = 2'b11
                        } axi_axbar_enum_t;

typedef enum axi_axsize_t {AXI1B   = 3'b000,
                           AXI2B   = 3'b001,
                           AXI4B   = 3'b010,
                           AXI8B   = 3'b011,
                           AXI16B  = 3'b100,
                           AXI32B  = 3'b101,
                           AXI64B  = 3'b110,
                           AXI128B = 3'b111
                        } axi_axsize_enum_t;

typedef enum int  {AXI4,
                   ACE,
                   ACE_LITE,
                   ACE_LITE_E
                   } axi_interface_enum_t;

typedef enum bit [2:0] {

  ACE_IX, ACE_SC, ACE_SD, ACE_UC, ACE_UD

} aceState_t;
typedef enum bit {
  NONCOH_ATM, COH_ATM
} aceAtomic_enum_t;

typedef enum axi_acsnoop_t {ACE_READ_ONCE               = 4'b0000,
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

typedef enum bit [2:0] {
    TLB_INVLD       = 3'b000,
    BP_INVLD        = 3'b001,
    PICI            = 3'b010,
    VICI            = 3'b011,
    SYNC            = 3'b100,
    HINT            = 3'b110
} dvm_msgType_enum_t;

