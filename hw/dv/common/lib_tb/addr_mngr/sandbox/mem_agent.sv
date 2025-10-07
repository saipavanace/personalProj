// mem_agent.sv
// Description: TBD
// Author: Sai Pavan Yaraguti

class mem_agent extends uvm_object;
    `uvm_object_utils(mem_agent)

    mem_agent_cfg m_mem_cfg;
    static local mem_agent m_ma;

    
        chiplet_mem_info chiplet0;
    
        chiplet_mem_info chiplet1;
    

    // Connectivity (built once per generate)
    giu_edge_t giu_forward_edges [2][4];

    extern function new(string name = "mem_agent");
    extern static  function mem_agent get();
    extern function void generate_memory_regions();
    extern function void initialize_chiplets_from_cfg();
    extern function void build_connectivity_from_links();
    extern function void fill_remaining_regions_with_policy();
    // Remote placement that enforces same-bounds + same-class at destination, without exceeding dest budget
    extern function bit try_place_one_remote_chain(int unsigned source_chiplet_id, ref chiplet_mem_info chiplets[$]);
    extern function bit exists_remote_pointing_to(const ref mem_info_t regions[$], int unsigned target_chiplet_id);
    extern function bit pick_outgoing_edge(input int unsigned src_c, output int unsigned dst_c, output int unsigned sel_link_id);
    extern task print_all_chiplets_region_table();

endclass: mem_agent

function mem_agent::new(string name = "mem_agent");
    super.new(name);
    m_mem_cfg = mem_agent_cfg::type_id::create("m_mem_cfg");
    
        chiplet0 = chiplet_mem_info::type_id::create("chiplet0");
    
        chiplet1 = chiplet_mem_info::type_id::create("chiplet1");
    
endfunction: new

function mem_agent mem_agent::get();
    if (m_ma == null)
        m_ma = new ();
    return m_ma;
endfunction : get

function void mem_agent::generate_memory_regions();
    if (m_mem_cfg.enable_custom_memregions) begin

    end else begin
        // 0) Wire per-chiplet inputs into chiplet_mem_info
        initialize_chiplets_from_cfg();

        // 1) Build local minima first (independent per chiplet)
        
            chiplet0.seed_local_minima();
        
            chiplet1.seed_local_minima();
        

        // 2) Build connectivity and place remote regions for remaining GPRAs
        build_connectivity_from_links();
        fill_remaining_regions_with_policy();

	// 3) (After remotes) sprinkle any extra IG locals if headroom remains
	
            chiplet0.maybe_add_extra_ig_regions();
        
            chiplet1.maybe_add_extra_ig_regions();
        

        // Done: chipletX.regions / region_owners hold the result
    end
endfunction: generate_memory_regions

// ----------------------------------------------------------
// Internal: initialize per-chiplet objects from cfg
// ----------------------------------------------------------
function void mem_agent::initialize_chiplets_from_cfg();
    
        chiplet0.chiplet_id        = 0;
        chiplet0.num_gpras_target  = m_mem_cfg.num_gpras_per_chiplet[0];
        chiplet0.num_igs           = m_mem_cfg.num_igs_per_chiplet[0];
        chiplet0.local_dii_units   = m_mem_cfg.dii_units[0];
        chiplet0.local_dmi_units   = m_mem_cfg.dmi_units[0];
    
        chiplet1.chiplet_id        = 1;
        chiplet1.num_gpras_target  = m_mem_cfg.num_gpras_per_chiplet[1];
        chiplet1.num_igs           = m_mem_cfg.num_igs_per_chiplet[1];
        chiplet1.local_dii_units   = m_mem_cfg.dii_units[1];
        chiplet1.local_dmi_units   = m_mem_cfg.dmi_units[1];
    
endfunction

// ----------------------------------------------------------
// Connectivity build for mem_agent scope (GIU usage tracking)
// ----------------------------------------------------------
function void mem_agent::build_connectivity_from_links();

    for (int unsigned c=0; c<2; c++) begin
        for (int unsigned g=0; g<4; g++) begin
            giu_forward_edges[c][g].present       = 0;
            giu_forward_edges[c][g].to_chiplet_id = '0;
            giu_forward_edges[c][g].to_giu_id     = '0;
        end
    end

    foreach (m_mem_cfg.fabric_links[link_idx]) begin
        int unsigned sc = m_mem_cfg.fabric_links[link_idx].from_chiplet_id;
        int unsigned sg = m_mem_cfg.fabric_links[link_idx].from_giu_id;
        int unsigned dc = m_mem_cfg.fabric_links[link_idx].to_chiplet_id;
        int unsigned dg = m_mem_cfg.fabric_links[link_idx].to_giu_id;
        giu_forward_edges[sc][sg].present       = 1;
        giu_forward_edges[sc][sg].to_chiplet_id = dc;
        giu_forward_edges[sc][sg].to_giu_id     = dg;

        // Mirror reverse direction (single entry implies bidirectional availability)
        giu_forward_edges[dc][dg].present       = 1;
        giu_forward_edges[dc][dg].to_chiplet_id = sc;
        giu_forward_edges[dc][dg].to_giu_id     = sg;
    end
endfunction

// ----------------------------------------------------------
// Fill remaining GPRAs per policy (remote vs local)
//  - Remote region HUT/HUI per rules, but enforce same-bounds + same-class on dest
//  - Never exceed per-chiplet num_gpras_target
// ----------------------------------------------------------

function void mem_agent::fill_remaining_regions_with_policy();
    chiplet_mem_info chiplets[$] = '{chiplet0, chiplet1}; // FIXME: Make this config independent
    int unsigned guard = 20000;
    bit placed = 0;
    int unsigned p;
    bit choose_remote;

    for (int unsigned c=0; c<2; c++) begin
        guard = 20000; // avoid infinite loop per chiplet - FIXME: should I add a check
        while ((chiplets[c].regions.size() < chiplets[c].num_gpras_target) && guard>0) begin
            guard--;

            placed = 0; // reset per-iteration
            p = m_mem_cfg.remote_probability_pct[c];
            choose_remote = ($urandom_range(0,99) < (p>100?100:p));

            // Try per policy
            if (choose_remote) placed = try_place_one_remote_chain(c, chiplets);
            if (!placed)       placed = chiplets[c].allocate_one_additional_local();

            // Second chance on the other path
            if (!placed && !choose_remote) placed = try_place_one_remote_chain(c, chiplets);
            if (!placed &&  choose_remote) placed = chiplets[c].allocate_one_additional_local();

            if (!placed) begin
                `uvm_warning("GPRAFILL", $sformatf(
                    "No placement possible for chiplet %0d (have %0d/need %0d). Breaking.",
                    c, chiplets[c].regions.size(), chiplets[c].num_gpras_target))
                break;
            end
        end
        if (guard==0) `uvm_warning("GPRAFILL", $sformatf(
            "Guard exhausted while filling chiplet %0d; got %0d/%0d regions.",
            c, chiplets[c].regions.size(), chiplets[c].num_gpras_target))
    end
endfunction

// Build a remote chain for SAME bounds & SAME class.
// 50/50 policy: half the time, try to REUSE an existing same-class LOCAL on dest
// (so the mirror costs zero budget); otherwise use random bounds (mirror consumes dest budget).
function bit mem_agent::try_place_one_remote_chain(int unsigned source_chiplet_id,
                                                   ref chiplet_mem_info chiplets[$]);
    int unsigned       dest_chiplet_id;
    int unsigned       selected_link_id;
    longint unsigned   base_addr;
    int unsigned       log2_size;
    bit [31:0]         lower_part1;
    bit  [8:0]         lower_part2;
    bit                choose_remote_dmi;
    bit [1:0]          hut_remote;
    bit [4:0]          hui_remote;
    bit [2:0]          link_id;
    region_owner_t     empty_owner_list[$];
    bit                prefer_reuse;
    bit                reuse_ok;

    // Need a link src -> dst
    if (!pick_outgoing_edge(source_chiplet_id, dest_chiplet_id, selected_link_id))
        return 0;

    // Pick remote class (DMI/DII)
    choose_remote_dmi = ($urandom_range(0,1) == 0);
    hut_remote        = choose_remote_dmi ? 2'b01 : 2'b11;   // remote DMI / remote DII
    hui_remote        = dest_chiplet_id[4:0];
    link_id           = selected_link_id[2:0];

    // 50/50: prefer reuse of an existing same-class LOCAL on destination
    prefer_reuse = ($urandom_range(0,1) == 0);
    reuse_ok     = 0;

    if (prefer_reuse) begin
        // Scan destination for an exact-bounds LOCAL of the required class and pick one at random
        int match_idxs[$];
        foreach (chiplets[dest_chiplet_id].regions[idx]) begin
            bit [1:0] hut_loc = chiplets[dest_chiplet_id].regions[idx].home_unit_type;
            if ((choose_remote_dmi && (hut_loc == 2'b00)) ||
                (!choose_remote_dmi && (hut_loc == 2'b10))) begin
                match_idxs.push_back(idx);
            end
        end

        if (match_idxs.size() > 0) begin
            int pick = match_idxs[$urandom_range(0, match_idxs.size()-1)];
            longint unsigned dst_lo_full =
                { chiplets[dest_chiplet_id].regions[pick].lower_part2,
                  chiplets[dest_chiplet_id].regions[pick].lower_part1, 12'b0 };
            int unsigned dst_sz_l2 = chiplets[dest_chiplet_id].regions[pick].size_log2;

            // Can the SOURCE host a region with these exact bounds (non-overlapping)?
            if (chiplets[source_chiplet_id].can_place_exact_region(dst_lo_full, dst_sz_l2)) begin
                base_addr = dst_lo_full;
                log2_size = dst_sz_l2;
                reuse_ok  = 1; // mirror already exists on dest → zero extra budget there
            end
        end
    end

    // If reuse path didn't work, use the normal random-bounds path (may consume dest budget)
    if (!reuse_ok) begin
        if (!chiplets[source_chiplet_id].choose_non_overlapping_region(base_addr, log2_size))
            return 0;

        // Ensure destination can TERMINATE or FORWARD within budget:
        if (choose_remote_dmi) begin
            // If exact local already exists on dest, we reuse it (budget-neutral). Otherwise we must create one.
            if (!chiplets[dest_chiplet_id].has_exact_region(2'b00, base_addr, log2_size)) begin
                int unsigned ig_sel;
                if (chiplets[dest_chiplet_id].num_igs == 0) return 0;
                if (chiplets[dest_chiplet_id].regions.size() >= chiplets[dest_chiplet_id].num_gpras_target) return 0;
                if (!chiplets[dest_chiplet_id].can_place_exact_region(base_addr, log2_size)) return 0;
                ig_sel = $urandom_range(0, chiplets[dest_chiplet_id].num_igs-1);
                if (!chiplets[dest_chiplet_id].append_exact_local_dmi_ig_region(ig_sel, base_addr, log2_size)) return 0;
            end
        end else begin
            if (!chiplets[dest_chiplet_id].has_exact_region(2'b10, base_addr, log2_size)) begin
                int unsigned ig_sel;
                int unsigned dii_idx;
                int unsigned dii_id;
                if (chiplets[dest_chiplet_id].local_dii_units.size() == 0) return 0;
                if (chiplets[dest_chiplet_id].regions.size() >= chiplets[dest_chiplet_id].num_gpras_target) return 0;
                if (!chiplets[dest_chiplet_id].can_place_exact_region(base_addr, log2_size)) return 0;
                dii_idx = $urandom_range(0, chiplets[dest_chiplet_id].local_dii_units.size()-1);
                dii_id  = chiplets[dest_chiplet_id].local_dii_units[dii_idx].funit_id;
                if (!chiplets[dest_chiplet_id].append_exact_local_dii_region(dii_id, base_addr, log2_size)) return 0;
            end
        end
    end

    // Finally add the REMOTE on SOURCE with SAME bounds pointing to DEST
    chiplets[source_chiplet_id].split_lower_into_parts(base_addr, lower_part1, lower_part2);
    chiplets[source_chiplet_id].append_region_with_owners(
        chiplets[source_chiplet_id].regions,
        chiplets[source_chiplet_id].region_owners,
        lower_part1, lower_part2,
        log2_size, hut_remote, hui_remote, link_id,
        empty_owner_list
    );

    return 1;
endfunction

// Scan if any region in 'regions' points remotely to target chiplet
function bit mem_agent::exists_remote_pointing_to(const ref mem_info_t regions[$], int unsigned target_chiplet_id);
    foreach (regions[ridx]) begin
        if (regions[ridx].home_unit_type[0] == 1'b1) begin
            if (regions[ridx].home_unit_identifier == target_chiplet_id[4:0]) return 1;
        end
    end
    return 0;
endfunction

// Pick an outgoing GIU edge
function bit mem_agent::pick_outgoing_edge(input int unsigned src_c,
                                           output int unsigned dst_c,
                                           output int unsigned sel_link_id);
    int candidate_gius[$];
    int s;
    int tmp;
    int unsigned g;
    for (int g=0; g<4; g++) if (giu_forward_edges[src_c][g].present) candidate_gius.push_back(g);
    if (candidate_gius.size() == 0) return 0;

    // shuffle
    for (int t=0; t<candidate_gius.size(); t++) begin
        s = $urandom_range(0, candidate_gius.size()-1);
        tmp = candidate_gius[t]; candidate_gius[t] = candidate_gius[s]; candidate_gius[s] = tmp;
    end

    foreach (candidate_gius[idx]) begin
        g = candidate_gius[idx];
        // No consumption: the same physical link can be referenced by multiple remote regions
        dst_c       = giu_forward_edges[src_c][g].to_chiplet_id;
        sel_link_id = g[2:0];
        return 1;
    end
    return 0;
endfunction

task mem_agent::print_all_chiplets_region_table();
    chiplet_mem_info chiplets[$];
    string hut_name;
    string order_name;
    string owner_str;
    string ig_str;
    int    c;
    int    r;
    int    o;
    longint unsigned lower_full;
    longint unsigned upper_full;
    longint unsigned size_bytes;

    chiplets = '{chiplet0, chiplet1}; // FIXME: Making this config independent

    $display("====================================================================================================================================================================================================================================================");
    $display("| Chiplet |               Addr Range                |  Size(log2)  |  HUT         |  HUI  | Region Kind     | Interleave/IG | LinkId |  NC  | NSX | Order | Owners                                                                                                     |");
    $display("====================================================================================================================================================================================================================================================");

    for (c = 0; c < 2; c++) begin
        // Chiplet header separator
        $display("----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
        $display("|   %0d    |                                                %-116s |", c, "");

        for (r = 0; r < chiplets[c].regions.size(); r++) begin
        lower_full = { chiplets[c].regions[r].lower_part2,
                        chiplets[c].regions[r].lower_part1,
                        12'b0 };
        size_bytes = (64'd1 << chiplets[c].regions[r].size_log2);
        upper_full = lower_full + size_bytes - 64'd1;

        case (chiplets[c].regions[r].home_unit_type)
            2'b00: hut_name = "DMI (local) ";
            2'b10: hut_name = "DII (local) ";
            2'b01: hut_name = "DMI (remote)";
            2'b11: hut_name = "DII (remote)";
            default: hut_name = "Unknown    ";
        endcase

        if (chiplets[c].regions[r].home_unit_type == 2'b00)
            ig_str = $sformatf("IG=%0d", chiplets[c].regions[r].home_unit_identifier);
        else
            ig_str = "";

        case (chiplets[c].regions[r].order)
            0: order_name = "Strong";
            1: order_name = "Strict";
            2: order_name = "Relaxed";
            default: order_name = "Posted";
        endcase

        owner_str = "";
        for (o = 0; o < chiplets[c].region_owners[r].size(); o++) begin
            if (o > 0) owner_str = {owner_str, ", "};
            owner_str = { owner_str,
                        $sformatf("C%0d:F%0d",
                                    chiplets[c].region_owners[r][o].chiplet_id,
                                    chiplets[c].region_owners[r][o].funit_id) };
        end

        if (owner_str == "") begin
            owner_str = hut_name;
        end

        $display("|   %0d    | { 0x%013h  0x%013h } |     %0d      |  %-11s | %4d | %-14s | %-13s |   %0d   |  %0d  |  %0d  | %-7s | %-100s |",
                c,
                lower_full, upper_full,
                chiplets[c].regions[r].size_log2,
                hut_name,
                chiplets[c].regions[r].home_unit_identifier,
                (chiplets[c].regions[r].home_unit_type == 2'b00) ? "GPA (DMI)" :
                (chiplets[c].regions[r].home_unit_type == 2'b10) ? "GPA (DII)" : "GPA",
                ig_str,
                chiplets[c].regions[r].link_id,
                chiplets[c].regions[r].nc,
                chiplets[c].regions[r].nsx,
                order_name,
                owner_str);
        end

        $display("|   %0d    |                                                %-116s |", c, "");
    end

    $display("====================================================================================================================================================================================================================================================");
endtask
