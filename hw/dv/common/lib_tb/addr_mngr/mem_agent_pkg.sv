// ============================================================
// Common typedefs and structs
// ===========================================================+

package mem_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import "DPI-C" function string getenv(input string env_name);

    typedef struct packed {
        bit [1:0] policy;
        bit       readid;
        bit       writeid;
    } order_t;

    typedef struct packed {
        bit [31:0]  lower_part1;            // lower[43:12]
        bit  [8:0]  lower_part2;            // lower[52:44]
        bit  [2:0]  target;                 // unused
        bit  [5:0]  size_log2;              // log2(size in bytes)
        order_t     order;                  // randomized
        bit         mig_nunitid;            // randomized
        bit         nc;                     // randomized
        bit         nsx;                    // randomized
        bit         interleave;             // 0 for now
        bit  [2:0]  link_id;                // GIU/link id when remote
        bit  [1:0]  home_unit_type;         // HUT
        bit  [5:0]  home_unit_identifier;   // HUI: IG id / DII FunitID / ChipletId
        bit  [52:0] full_lower_addr;   // HUI: IG id / DII FunitID / ChipletId
        bit  [52:0] full_upper_addr;   // HUI: IG id / DII FunitID / ChipletId
    } mem_info_t;

    typedef struct packed {
        int unsigned chiplet_id;
        int unsigned funit_id;
    } region_owner_t;

    typedef struct packed {
        int unsigned funit_id;               // DII
    } dii_unit_t;

    typedef struct packed {
        int unsigned funit_id;               // DMI
        int unsigned ig_id;                  // Interleaving group id (0..nIGs-1)
    } dmi_unit_t;

    typedef struct packed {
        int unsigned from_chiplet_id;
        int unsigned to_chiplet_id;
        int unsigned from_giu_id;
        int unsigned to_giu_id;
    } link_t;

    typedef struct packed {
        bit          present;
        int unsigned to_chiplet_id;
        int unsigned to_giu_id;
    } giu_edge_t;

    `include "chiplet_mem_info.sv"
    `include "mem_agent_cfg.sv"
    `include "mem_agent.sv"

endpackage: mem_agent_pkg