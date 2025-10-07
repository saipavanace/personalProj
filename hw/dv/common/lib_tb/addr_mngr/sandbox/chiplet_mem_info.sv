//
//
//

class chiplet_mem_info extends uvm_object;
    `uvm_object_utils(chiplet_mem_info)
    int unsigned chiplet_id;
    int unsigned num_gpras_target; //FIXME: Get this value from JSON
    int unsigned num_igs; //FIXME: Get this value from JSON
    dii_unit_t   local_dii_units[$];
    dmi_unit_t   local_dmi_units[$];

    // Generated outputs
    mem_info_t       regions[$];
    region_owner_t   region_owners[$][$];

    // Addressing constraints
    localparam int unsigned ADDRESS_WIDTH_BITS    = 53;
    localparam longint unsigned ADDRESS_MAX_VALUE = (64'd1 << ADDRESS_WIDTH_BITS) - 64'd1;
    localparam int unsigned MIN_LOG2_REGION_SIZE  = 12; // 4KB
    localparam int unsigned MAX_LOG2_REGION_SIZE  = 45; // 32TB

    function new(string name = "chiplet_mem_info");
        super.new(name);
    endfunction

    // ---------- Public API called by mem_agent ----------

    // Seed mandatory locals: ≥1 per DII (exclusive) and ≥1 per IG (shared by DMIs in IG)
    function void seed_local_minima();
        allocate_local_minimum_for_all_diis();
        allocate_local_minimum_for_all_dmi_igs();
    endfunction

    // Optional: add extra IG-owned regions randomly (shared by IG DMIs)
    function void maybe_add_extra_ig_regions(int unsigned max_attempts = 0);
        int unsigned attempts;
        int unsigned ig_id;
        attempts = (max_attempts == 0) ? num_igs : max_attempts;
        while ((attempts > 0) && (regions.size() < num_gpras_target)) begin
            attempts = attempts - 1;
            if ($urandom_range(0,99) < 40) begin
                if (num_igs > 0) begin
                    ig_id = $urandom_range(0, num_igs-1);
                    void'(allocate_one_local_dmi_ig_region(ig_id));
                end
            end
        end
    endfunction

    function bit allocate_one_additional_local();
        bit choose_dii_path;
        choose_dii_path = ($urandom_range(0,1) == 0);
        if (choose_dii_path && (local_dii_units.size() > 0))
            return allocate_one_local_dii_region(local_dii_units[$urandom_range(0, local_dii_units.size()-1)].funit_id);
        else if (num_igs > 0)
            return allocate_one_local_dmi_ig_region($urandom_range(0, num_igs-1));
        else
            return 0;
    endfunction

    function void allocate_local_minimum_for_all_diis();
        int dii_index;
        for (dii_index = 0; dii_index < local_dii_units.size(); dii_index++) begin
            void'(allocate_one_local_dii_region(local_dii_units[dii_index].funit_id));
        end
    endfunction

    function void allocate_local_minimum_for_all_dmi_igs();
        int unsigned ig_id;
        for (ig_id = 0; ig_id < num_igs; ig_id++) begin
            void'(allocate_one_local_dmi_ig_region(ig_id));
        end
    endfunction

    function bit allocate_one_local_dii_region(int unsigned dii_funit_id);
        longint unsigned base_addr;
        int unsigned     log2_size;
        bit [31:0]       lower_part1;
        bit  [8:0]       lower_part2;
        bit [1:0]        hut;
        bit [4:0]        hui;
        bit [2:0]        link_id;
        region_owner_t   owners_for_region[$];

        if (!choose_non_overlapping_region(base_addr, log2_size)) return 0;
        split_lower_into_parts(base_addr, lower_part1, lower_part2);
        hut = 2'b10;
        hui = dii_funit_id[4:0];
        link_id = 3'd0;

        owners_for_region.push_back('{chiplet_id, dii_funit_id});
        append_region_with_owners(regions, region_owners, lower_part1, lower_part2, log2_size, hut, hui, link_id, owners_for_region);
        return 1;
    endfunction

    function bit allocate_one_local_dmi_ig_region(int unsigned ig_id);
        longint unsigned base_addr;
        int unsigned     log2_size;
        bit [31:0]       lower_part1;
        bit  [8:0]       lower_part2;
        bit [1:0]        hut;
        bit [4:0]        hui;
        bit [2:0]        link_id;
        region_owner_t   owners_for_region[$];
        int              dmi_idx;

        if (!choose_non_overlapping_region(base_addr, log2_size)) return 0;
        split_lower_into_parts(base_addr, lower_part1, lower_part2);
        hut = 2'b00;
        hui = ig_id[4:0];
        link_id = 3'd0;

        for (dmi_idx = 0; dmi_idx < local_dmi_units.size(); dmi_idx++) begin
            if (local_dmi_units[dmi_idx].ig_id == ig_id)
                owners_for_region.push_back('{chiplet_id, local_dmi_units[dmi_idx].funit_id});
        end
        append_region_with_owners(regions, region_owners, lower_part1, lower_part2,log2_size, hut, hui, link_id, owners_for_region);
        return 1;
    endfunction

    // ---------------- NEW helpers for exact-bounds placement ----------------

    // Check if a given (base,size) would be non-overlapping on THIS chiplet
    function bit can_place_exact_region(input longint unsigned base_addr,
                                        input int unsigned log2_size);
        longint unsigned size_bytes      = (64'd1 << log2_size);
        longint unsigned candidate_upper = base_addr + size_bytes - 64'd1;
        foreach (regions[idx]) begin
            longint unsigned existing_lo_full = { regions[idx].lower_part2, regions[idx].lower_part1, 12'b0 };
            longint unsigned existing_hi_full = existing_lo_full + (64'd1 << regions[idx].size_log2) - 64'd1;
            if (!((candidate_upper < existing_lo_full) || (existing_hi_full < base_addr))) begin
                return 0;
            end
        end
        return 1;
    endfunction

    // Does an EXACT region already exist with SAME bounds and SAME class (hut)?
    function bit has_exact_region(input bit [1:0] hut_value,
                                  input longint unsigned base_addr,
                                  input int unsigned log2_size);
        foreach (regions[idx]) begin
            longint unsigned existing_lo_full = { regions[idx].lower_part2, regions[idx].lower_part1, 12'b0 };
            if ((regions[idx].home_unit_type == hut_value) &&
                (regions[idx].size_log2 == log2_size[5:0]) &&
                (existing_lo_full == base_addr)) begin
                return 1;
            end
        end
        return 0;
    endfunction

    // Append exact-bounds LOCAL DII region (owners = single DII)
    function bit append_exact_local_dii_region(input int unsigned dii_funit_id,
                                               input longint unsigned base_addr,
                                               input int unsigned log2_size);
        bit [31:0] lower_part1; bit [8:0] lower_part2;
        region_owner_t owners_for_region[$];

        if (!can_place_exact_region(base_addr, log2_size)) return 0;
        split_lower_into_parts(base_addr, lower_part1, lower_part2);
        owners_for_region.push_back('{chiplet_id, dii_funit_id});
        append_region_with_owners(regions, region_owners, lower_part1, lower_part2,
                                  log2_size, 2'b10, dii_funit_id[4:0], 3'd0, owners_for_region);
        return 1;
    endfunction

    // Append exact-bounds LOCAL DMI IG region (owners = all DMIs in IG)
    function bit append_exact_local_dmi_ig_region(input int unsigned ig_id,
                                                  input longint unsigned base_addr,
                                                  input int unsigned log2_size);
        region_owner_t owners_for_region[$];
        bit [31:0] lower_part1; bit [8:0] lower_part2;

        if (!can_place_exact_region(base_addr, log2_size)) return 0;
        split_lower_into_parts(base_addr, lower_part1, lower_part2);
        foreach (local_dmi_units[dmi_idx]) begin
            if (local_dmi_units[dmi_idx].ig_id == ig_id)
                owners_for_region.push_back('{chiplet_id, local_dmi_units[dmi_idx].funit_id});
        end
        append_region_with_owners(regions, region_owners, lower_part1, lower_part2,
                                  log2_size, 2'b00, ig_id[4:0], 3'd0, owners_for_region);
        return 1;
    endfunction

    // ---------------- Utilities ----------------
    function bit choose_non_overlapping_region(output longint unsigned base_addr, output int unsigned log2_size);
        longint unsigned size_bytes;
        int attempt_budget;
        longint unsigned max_base;
        longint unsigned candidate_upper;
        bit overlap;
        int region_index;
        longint unsigned existing_lo_full;
        longint unsigned existing_hi_full;
        longint unsigned rand64;

        log2_size = $urandom_range(MIN_LOG2_REGION_SIZE, MAX_LOG2_REGION_SIZE);
        size_bytes = (64'd1 << log2_size);
        attempt_budget = 2000;
        while (attempt_budget > 0) begin
            attempt_budget = attempt_budget - 1;
            max_base = ((ADDRESS_MAX_VALUE + 64'd1) > size_bytes) ?
                       ((ADDRESS_MAX_VALUE + 64'd1) - size_bytes) : 0;
            if (max_base == 0) return 0;
            rand64    = { $urandom(), $urandom() };
            base_addr = rand64 % (max_base + 64'd1);
            base_addr = base_addr & ~((64'd1 << log2_size) - 64'd1); // align to size
            candidate_upper = base_addr + size_bytes - 64'd1;
            overlap = 0;
            for (region_index = 0; region_index < regions.size(); region_index++) begin
                existing_lo_full = { regions[region_index].lower_part2, regions[region_index].lower_part1, 12'b0 };
                existing_hi_full = existing_lo_full + (64'd1 << regions[region_index].size_log2) - 64'd1;
                if (!((candidate_upper < existing_lo_full) || (existing_hi_full < base_addr))) begin
                    overlap = 1;
                    break;
                end
            end
            if (!overlap) return 1;
        end
        return 0;
    endfunction

    function void split_lower_into_parts(input longint unsigned base_addr, output bit [31:0] lower_part1_out, output bit [8:0] lower_part2_out);
        lower_part1_out = base_addr[43:12];
        lower_part2_out = base_addr[52:44];
    endfunction

    function void append_region_with_owners(
        ref mem_info_t       region_vec[$],
        ref region_owner_t   owners_vec_of_vec[$][$],
        input bit [31:0]     lower_part1_in,
        input bit  [8:0]     lower_part2_in,
        input int unsigned   region_log2_size,
        input bit [1:0]      hut_value,
        input bit [4:0]      hui_value,
        input bit [2:0]      link_id_value,
        input region_owner_t owner_list[$]);
        mem_info_t region;
        region.lower_part1          = lower_part1_in;
        region.lower_part2          = lower_part2_in;
        region.size_log2            = region_log2_size[5:0];
        region.order                = $urandom_range(0, 15);
        region.mig_nunitid          = $urandom_range(0, 1);
        region.nc                   = $urandom_range(0, 1);
        region.nsx                  = $urandom_range(0, 1);
        region.interleave           = 1'b0;
        region.link_id              = link_id_value;
        region.home_unit_type       = hut_value;
        region.home_unit_identifier = hui_value;
        region.target               = 3'b000;
        region_vec.push_back(region);
        owners_vec_of_vec.push_back(owner_list);
    endfunction

endclass: chiplet_mem_info
