//
//DCE Sequence Package Typedefs
//

typedef bit [addrMgrConst::WCACHE_OFFSET - 1 : 0] blockoffset_width_t;
typedef bit [addrMgrConst::W_SEC_ADDR - 1 : addrMgrConst::WCACHE_OFFSET] cacheblock_addr_width_t;
typedef bit [addrMgrConst::W_SEC_ADDR - 1 : 0] addr_width_t;
typedef enum int {
  IX, SC, SD, UC, UD, UDP, UCE
} ncore_cache_state_t;
