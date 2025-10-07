//
//DCE Sequence Package Typedefs
//

typedef bit [ncoreConfigInfo::WCACHE_OFFSET - 1 : 0] blockoffset_width_t;
typedef bit [ncoreConfigInfo::W_SEC_ADDR - 1 : ncoreConfigInfo::WCACHE_OFFSET] cacheblock_addr_width_t;
typedef bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr_width_t;
typedef enum int {
  IX, SC, SD, UC, UD, UDP, UCE
} ncore_cache_state_t;
