//-------------------------------------------------------------------------------------------------- 
// APB Parameters
//-------------------------------------------------------------------------------------------------- 

// This needs to be defined in build_tb_env
typedef bit [WPADDR-1:0]          apb_paddr_t;
typedef bit [WPWRITE-1:0]         apb_pwrite_t;
typedef bit [WPSEL-1:0]           apb_psel_t;
typedef bit [WPPROT-1:0]          apb_pprot_t;
typedef bit [WPSTRB-1:0]          apb_pstrb_t;
typedef bit [WPENABLE-1:0]        apb_penable_t;
typedef bit [WPRDATA-1:0]         apb_prdata_t;
typedef bit [WPWDATA-1:0]         apb_pwdata_t;
typedef bit [WPREADY-1:0]         apb_pready_t;
typedef bit [WPSLVERR-1:0]        apb_pslverr_t;

// This needs to be defined in build_tb_env
typedef logic [WPADDR-1:0]          apb_paddr_logic_t;
typedef logic [WPWRITE-1:0]         apb_pwrite_logic_t;
typedef logic [WPSEL-1:0]           apb_psel_logic_t;
typedef logic [WPPROT-1:0]          apb_pprot_logic_t;
typedef logic [WPSTRB-1:0]          apb_pstrb_logic_t;
typedef logic [WPENABLE-1:0]        apb_penable_logic_t;
typedef logic [WPRDATA-1:0]         apb_prdata_logic_t;
typedef logic [WPWDATA-1:0]         apb_pwdata_logic_t;
typedef logic [WPREADY-1:0]         apb_pready_logic_t;
typedef logic [WPSLVERR-1:0]        apb_pslverr_logic_t;

//--------------------------------------------------------------------------------------------------
// Enums Functions for APB packets that have predefined types 
//-------------------------------------------------------------------------------------------------- 

// enum only supported types
typedef enum apb_pwrite_t {APB_RD   = 1'b0,
                           APB_WR     = 1'b1
                          } apb_pwrite_enum_t;

typedef enum apb_pslverr_t {NULL   = 1'b0,
                            ERR    = 1'b1
                           } apb_pslverr_enum_t;

