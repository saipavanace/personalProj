// The entire notice above must be reproduced on all authorized copies.
//----------------------------------------------------------------------------------------------------------------
// File     : plru_model.sv
// Author   : yramasamy
// Notes    : models the plru tree and mehtods to verify it
//----------------------------------------------------------------------------------------------------------------

`ifndef __PLRU_MODEL_SV__
`define __PLRU_MODEL_SV__

virtual class plru_model_base extends uvm_object;
    pure virtual function int  generate_plru_tree        (int state_q[$], int way_cnt, int state_xtn_q[$], int node, int level);
    pure virtual function int  check_plru_logic          (int set_index, int evicted_way, int busy_ways, int unalloc_ways, bit donot_error_on_mismatch=0);
    pure virtual function void update_plru_state_on_hit  (int set_index, int hit_way);
    pure virtual function int  move_to_next_state        (int set_index, int busy_ways, int unalloc_ways);
    pure virtual function void compute_state_override    (int valid_ways, int set_index, int busy_ways, int unalloc_ways);
endclass: plru_model_base

class plru_model #(int NSETS, int NWAYS) extends plru_model_base;
    // members of the class
    //---------------------------------------------------------------------------------------------------------------
    string            m_inst_name;
    logic [NWAYS-2:0] m_way2state_map      [NWAYS];
    logic [NWAYS-2:0] m_way2state_mask     [NWAYS];
    bit   [NWAYS-1:0] m_state_override_mask[NWAYS-1][2];
    int               m_state_override     [NWAYS-1][2][$];
    int               m_plru_state_tracker [int];
    int               m_state2way_map      [int];

    // covergroup definition
    //---------------------------------------------------------------------------------------------------------------
    covergroup plru_covergroup with function sample(int plru_state, int set_index, int victim_way, logic [NWAYS-1:0] valid_ways);
        //#Cover.DCE.v36.PlruAccess
        cp_set_index: coverpoint set_index {
            bins set_index_bin[16] = {0, [1:NSETS-2], NSETS-1};
        }

        cp_victim_way: coverpoint victim_way {
            bins victim_way_bin[] = {[0:NWAYS-1]};
        }

        cross_set_index_X_victim_way: cross cp_set_index, cp_victim_way {
            ignore_bins ignore_non0_setidx = cross_set_index_X_victim_way with (cp_set_index != 0);
        }

        // reference: https://www.amiq.com/consulting/2018/01/15/how-to-alternative-ways-to-implement-bitwise-coverage/
        //#Cover.DCE.v36.PlruStates
        cp_plru_state_onehot: coverpoint ($clog2(plru_state + {{(NWAYS-1){1'b0}}, 1'b1 }) - 1) iff (plru_state != 0) {
            bins plru_state_onehot_bin[] = {[0:NWAYS-2]};
        }

        // reference: https://www.amiq.com/consulting/2018/01/15/how-to-alternative-ways-to-implement-bitwise-coverage/
        //#Cover.DCE.v36.PlruValidWays
        cp_valid_ways_onehot: coverpoint ($clog2(valid_ways + {{NWAYS{1'b0}}, 1'b1 }) - 1) iff (valid_ways != 0) {
            bins valid_way_onehot_bin[] = {[0:NWAYS-1]};
        }
    endgroup

    // function: new
    //---------------------------------------------------------------------------------------------------------------
    function new(string name = "plru_model");
        int     l_way_cnt, r_way_cnt;
        string  stat;

        m_inst_name = name;

        // creating covergroup instance
        //-----------------------------------------------------------------------------------------------------------
        plru_covergroup = new();
        
        // generating the tree
        //-----------------------------------------------------------------------------------------------------------
        if(NWAYS % 2 == 1) begin
           `uvm_fatal(m_inst_name, $psprintf("[%-35s] doesnt support odd number of ways! (NWAYS=%1d)", "plruModel-Setup", NWAYS));
        end
        else if (NWAYS < 2) begin
           `uvm_fatal(m_inst_name, $psprintf("[%-35s] doesnt support ways less than 2! (NWAYS=%1d)", "plruModel-Setup", NWAYS));
        end
        else if (NWAYS > 32) begin
           `uvm_fatal(m_inst_name, $psprintf("[%-35s] number of ways cant be more than 32! (NWAYS=%1d)", "plruModel-Setup", NWAYS));
        end
        else begin
            l_way_cnt = generate_plru_tree(.state_q('{0}), .way_cnt(0        ), .state_xtn_q('{0}), .node(0), .level(1)); 
            r_way_cnt = generate_plru_tree(.state_q('{0}), .way_cnt(l_way_cnt), .state_xtn_q('{1}), .node(1), .level(1)); 
        end

        // printing the override
        //-----------------------------------------------------------------------------------------------------------
        for(int i=0; i < NWAYS-1; i++) begin
            stat = $psprintf("[%-35s] State[%2d].[0] override ways :: (%b) >>", "plruModel-OverrideSetup", i, m_state_override_mask[i][0]);
            foreach(m_state_override[i][0][j]) begin
                stat = $psprintf("%s %2d,", stat, m_state_override[i][0][j]);
            end
           `uvm_info(m_inst_name, stat, UVM_NONE);

            stat = $psprintf("[%-35s] State[%2d].[1] override ways :: (%b) >>", "plruModel-OverrideSetup", i, m_state_override_mask[i][1]);
            foreach(m_state_override[i][1][j]) begin
                stat = $psprintf("%s %2d,", stat, m_state_override[i][1][j]);
            end
           `uvm_info(m_inst_name, stat, UVM_NONE);
        end

        // generating the state to way map
        //-----------------------------------------------------------------------------------------------------------
        for(int i=0; i < (2**(NWAYS-1)); i++) begin
            for(int j=0; j < NWAYS; j++) begin
                if((m_way2state_map[j] & m_way2state_mask[j]) == (i & m_way2state_mask[j])) begin
                    m_state2way_map[i] = j;
                    //`uvm_info(m_inst_name, $psprintf("[%-35s] [stateVector: 'b%32b (%2d)] -> [way-%3d]", "plruModel-State2WayMap", i, i, j), UVM_DEBUG);
                    break;
                end
            end
        end
    endfunction: new
    
    // function: generate_plru_tree
    //           function that generates the plru tree with state overrides
    //---------------------------------------------------------------------------------------------------------------
    virtual function int generate_plru_tree(int state_q[$], int way_cnt, int state_xtn_q[$], int node, int level);
        int     l_way_cnt;
        int     r_way_cnt;
        int     lvl_nodes    = (2**level);
        int     lvl_offset   = (2**level)-1;
        int     node_spacing = 1;
        int     this_node_id;
        string  stat;
        
        // choosing the growth levels
        if(NWAYS-1 > lvl_offset) begin
          
            // computing this node id, accounting for incomplete levels when NWAYS is not a power of 2
            if(NWAYS-1-lvl_offset < lvl_nodes) begin
                node_spacing = lvl_nodes/(NWAYS-1-lvl_offset);
            end
            this_node_id = (node/node_spacing)+lvl_offset;
              
            // check for growth node
            if(node % node_spacing == 0) begin
                // grow the next level nodes
                state_q.push_back(this_node_id);
                state_xtn_q.push_back(0);
                l_way_cnt = generate_plru_tree(.state_q(state_q), .way_cnt(way_cnt  ), .state_xtn_q(state_xtn_q), .node((node*2)+0), .level(level+1)); 
                
                state_xtn_q[$] = 1;
                r_way_cnt = generate_plru_tree(.state_q(state_q), .way_cnt(l_way_cnt), .state_xtn_q(state_xtn_q), .node((node*2)+1), .level(level+1));

                way_cnt = r_way_cnt;
                state_q.pop_back();
                state_xtn_q.pop_back();
            end
                 
            // leaf node
            else begin
                 m_way2state_mask[way_cnt] = 'd0;
                 foreach(state_q[i]) begin
                    m_way2state_map [way_cnt][state_q[i]] = state_xtn_q[i];
                    m_way2state_mask[way_cnt][state_q[i]] = 1;
                    m_state_override[state_q[i]][state_xtn_q[i]].push_back(way_cnt);
                    m_state_override_mask[state_q[i]][state_xtn_q[i]][way_cnt] = 1'b1;
                    stat = $psprintf("%s %2d(%2d),", stat, state_q[i], state_xtn_q[i]);
                 end
                 stat = $psprintf("[%-35s] [way: %2d / %2d] {check: %2d == %2d} >> states(%b -> %b) >> %s", "plruModel-WaySetup", way_cnt, NWAYS, state_q.size(), state_xtn_q.size(), m_way2state_map[way_cnt], m_way2state_map[way_cnt] ^ m_way2state_mask[way_cnt], stat);
                `uvm_info(m_inst_name, stat, UVM_NONE);
                 way_cnt = way_cnt+1;
            end
        end
               
        // leaf node
        else begin
            m_way2state_mask[way_cnt] = 'd0;
            foreach(state_q[i]) begin
                m_way2state_map [way_cnt][state_q[i]] = state_xtn_q[i];
                m_way2state_mask[way_cnt][state_q[i]] = 1;
                m_state_override[state_q[i]][state_xtn_q[i]].push_back(way_cnt);
                m_state_override_mask[state_q[i]][state_xtn_q[i]][way_cnt] = 1'b1;
                stat = $psprintf("%s %2d(%2d),", stat, state_q[i], state_xtn_q[i]);
            end
            stat = $psprintf("[%-35s] [way: %2d / %2d] {check: %2d == %2d} >> states(%b -> %b) >> %s", "plruModel-WaySetup", way_cnt, NWAYS, state_q.size(), state_xtn_q.size(), m_way2state_map[way_cnt], m_way2state_map[way_cnt] ^ m_way2state_mask[way_cnt], stat);
         `  uvm_info(m_inst_name, stat, UVM_NONE);
            way_cnt = way_cnt+1;
        end

        return(way_cnt);
    endfunction: generate_plru_tree
    
    // function: check_plru_logic
    //           function that tracks the plru state transition and evaluates the evicted way
    //---------------------------------------------------------------------------------------------------------------
    virtual function int check_plru_logic(int set_index, int evicted_way, int busy_ways, int unalloc_ways, bit donot_error_on_mismatch=0);
        int               victim_way;
        logic [NWAYS-2:0] prev_state;
        logic [NWAYS-1:0] valid_ways;

        busy_ways    = busy_ways[NWAYS-1:0];
        unalloc_ways = unalloc_ways[NWAYS-1:0];
        valid_ways   = (|unalloc_ways) ? unalloc_ways : ~busy_ways;

        // initiate plru entry if index used for the first time
        if(!m_plru_state_tracker.exists(set_index)) begin
            m_plru_state_tracker[set_index] = 'd0;
            if($countones(valid_ways) < NWAYS) begin
                if(donot_error_on_mismatch == 1) begin
                   `uvm_warning(m_inst_name, $psprintf("[%-35s] valid ways not all 1s! (nWays: %1d, setIdx: 0x%08h, busyWays: 0x%08h, unallocWays: 0x%08h, validWays: 0x%08h)", "plruModel-NewLineCheck(Alloc)", NWAYS, set_index, busy_ways, unalloc_ways, valid_ways));
                    return(1); // return on error
                end
                else begin
                   `uvm_error(m_inst_name, $psprintf("[%-35s] valid ways not all 1s! (nWays: %1d, setIdx: 0x%08h, busyWays: 0x%08h, unallocWays: 0x%08h, validWays: 0x%08h)", "plruModel-NewLineCheck(Alloc)", NWAYS, set_index, busy_ways, unalloc_ways, valid_ways));
                end
            end
        end

        if(valid_ways == 'd0) begin
            if(donot_error_on_mismatch == 1) begin
               `uvm_warning(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [busyWays: 0x%08h] [unallocWays: 0x%08h] [validWays: 0x%08h]", "plruModel-Alloc-NoVldWays", NWAYS, set_index, busy_ways, unalloc_ways, valid_ways));
                return(1); // return on error
            end
            else begin
               `uvm_fatal(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [busyWays: 0x%08h] [unallocWays: 0x%08h] [validWays: 0x%08h]", "plruModel-Alloc-NoVldWays", NWAYS, set_index, busy_ways, unalloc_ways, valid_ways));
            end
        end
        else begin
            // evaluating the plru overrides
            compute_state_override(valid_ways, set_index, busy_ways, unalloc_ways);

            // check against observed plru
            if(m_state2way_map.exists(m_plru_state_tracker[set_index])) begin
                victim_way = m_state2way_map[m_plru_state_tracker[set_index]];
                if(victim_way != evicted_way) begin
                    if(donot_error_on_mismatch == 1) begin
                       `uvm_warning(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [stateTracker: 0x%08h] [exptWay: %2d != %2d: obsvWay]", "plruModel-ExptWayNotFound", NWAYS, set_index, m_plru_state_tracker[set_index], victim_way, evicted_way));
                        return(1);
                    end
                    else begin
                       `uvm_error(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [stateTracker: 0x%08h] [exptWay: %2d != %2d: obsvWay]", "plruModel-ExptWayNotFound", NWAYS, set_index, m_plru_state_tracker[set_index], victim_way, evicted_way));
                    end
                end
                else begin
                    prev_state   = m_plru_state_tracker[set_index];
                    m_plru_state_tracker[set_index] = m_plru_state_tracker[set_index] ^ m_way2state_mask[victim_way];
                   `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [stateWayMap: %b] [stateWayMask: 0x%08h] [stateTracker: 0x%08h -> 0x%08h] [exptWay: %2d == %2d: obsvWay]", "plruModel-ExptWayFound", NWAYS, set_index, m_way2state_map[victim_way], m_way2state_mask[victim_way], prev_state, m_plru_state_tracker[set_index], victim_way, evicted_way), UVM_MEDIUM);
                    plru_covergroup.sample(m_plru_state_tracker[set_index], set_index, victim_way, valid_ways);
                end
            end
            else begin
               `uvm_fatal(m_inst_name, $psprintf("[%-35s] unable to find a matching state-way map! might be a model issue! [obsvWay: %2d]", "plruModel-NoExptWay!", evicted_way));
            end
        end
        return(0); // no error return
    endfunction: check_plru_logic

    // function: update_plru_state_on_hit
    //           function that update lru when a cache line is hit
    //---------------------------------------------------------------------------------------------------------------
    virtual function void update_plru_state_on_hit(int set_index, int hit_way);
        int               victim_way;
        logic [NWAYS-2:0] prev_state;

        if(!m_plru_state_tracker.exists(set_index)) begin
           `uvm_fatal(m_inst_name, $psprintf("[%-35s] noticed a hit for a set that was not allocated! [set_index: 0x%04h ('d%1d)] [way: %3d]", "plruModel-UnExptHit", set_index, set_index, hit_way));
        end
        else begin
            prev_state                      = m_plru_state_tracker[set_index];
            m_plru_state_tracker[set_index] = (prev_state & ~m_way2state_mask[hit_way]) | ((m_way2state_map[hit_way] & m_way2state_mask[hit_way]) ^ m_way2state_mask[hit_way]); //CONC-12807 update
            victim_way                      = m_state2way_map[m_plru_state_tracker[set_index]];
            plru_covergroup.sample(m_plru_state_tracker[set_index], set_index, victim_way, 'd0);
           `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [stateWayMap: %b] [stateWayMask: 0x%08h] [stateTracker: 0x%08h] [prevState: 0x%08h] [mru->lru: %2d -> %2d]", "plruModel-UpdateStateOnHit", NWAYS, set_index, m_way2state_map[hit_way], m_way2state_mask[hit_way], m_plru_state_tracker[set_index], prev_state, hit_way, victim_way), UVM_MEDIUM);
        end
    endfunction: update_plru_state_on_hit
    
    // function: move_to_next_state
    //           function that moves the plru to next state
    //---------------------------------------------------------------------------------------------------------------
    virtual function int move_to_next_state(int set_index, int busy_ways, int unalloc_ways);
        int               victim_way;
        logic [NWAYS-2:0] prev_state;
        logic [NWAYS-1:0] valid_ways;

        busy_ways    = busy_ways[NWAYS-1:0];
        unalloc_ways = unalloc_ways[NWAYS-1:0];
        valid_ways   = (|unalloc_ways) ? unalloc_ways : ~busy_ways;

        // initiate plru entry if index used for the first time
        if(!m_plru_state_tracker.exists(set_index)) begin
            m_plru_state_tracker[set_index] = 'd0;
            if($countones(valid_ways) < NWAYS) begin
               `uvm_error(m_inst_name, $psprintf("[%-35s] valid ways not all 1s! (nWays: %1d, setIdx: 0x%08h, busyWays: 0x%08h, unallocWays: 0x%08h, validWays: 0x%08h)", "plruModel-NewLineCheck(Move)", NWAYS, set_index, busy_ways, unalloc_ways, valid_ways));
            end
        end

        if(valid_ways == 'd0) begin
           `uvm_fatal(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [busyWays: 0x%08h] [unallocWays: 0x%08h] [validWays: 0x%08h]", "plruModel-Move2Nxt-NoVldWays", NWAYS, set_index, busy_ways, unalloc_ways, valid_ways));
        end
        else begin
            // evaluating the plru overrides
            compute_state_override(valid_ways, set_index, busy_ways, unalloc_ways);

            // check against observed plru
            if(m_state2way_map.exists(m_plru_state_tracker[set_index])) begin
                victim_way   = m_state2way_map[m_plru_state_tracker[set_index]];
                prev_state   = m_plru_state_tracker[set_index];
                m_plru_state_tracker[set_index] = m_plru_state_tracker[set_index] ^ m_way2state_mask[victim_way];
               `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [stateWayMap: %b] [stateWayMask: 0x%08h] [stateTracker: 0x%08h -> 0x%08h] [victimWay: %2d]", "plruModel-Move2Nxt", NWAYS, set_index, m_way2state_map[victim_way], m_way2state_mask[victim_way], prev_state, m_plru_state_tracker[set_index], victim_way), UVM_MEDIUM);
                plru_covergroup.sample(m_plru_state_tracker[set_index], set_index, victim_way, valid_ways);
                return(victim_way);
            end
        end
    endfunction: move_to_next_state
    
    // function: compute_state_override
    //           function that computes state overrides
    //---------------------------------------------------------------------------------------------------------------
    virtual function void compute_state_override(int valid_ways, int set_index, int busy_ways, int unalloc_ways);
        logic [NWAYS-2:0] prev_state;

        if(&valid_ways == 0) begin
            prev_state = m_plru_state_tracker[set_index];
           `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [busyWays: 0x%08h] [unallocWays: 0x%08h] [validWays: 0x%08h]", "plruModel-StateOverrideInit", NWAYS, set_index, busy_ways, unalloc_ways, valid_ways), UVM_MEDIUM);
            for(int i=0; i < NWAYS-1; i++) begin
                if(((valid_ways & (m_state_override_mask[i][0] | m_state_override_mask[i][1])) == 0)) begin // CONC-12807,  update
                   `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [validWays: 0x%08h] [stateOverrideMask: 0x%08h] [state: 0x%08h, bit-%2d]", "plruModel-StateOverride-Skip", NWAYS, set_index, valid_ways, m_state_override_mask[i][0] | m_state_override_mask[i][1], m_plru_state_tracker[set_index], i), UVM_MEDIUM);
                end
                else if((valid_ways & m_state_override_mask[i][0]) == 0) begin
                    m_plru_state_tracker[set_index][i] = 1'b1;
                   `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [validWays: 0x%08h] [stateOverrideMask: 0x%08h] [state: 0x%08h, bit-%2d]", "plruModel-StateOverride-0", NWAYS, set_index, valid_ways, m_state_override_mask[i][0], m_plru_state_tracker[set_index], i), UVM_MEDIUM);
                end
                else if((valid_ways & m_state_override_mask[i][1]) == 0) begin
                    m_plru_state_tracker[set_index][i] = 1'b0;
                   `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [validWays: 0x%08h] [stateOverrideMask: 0x%08h] [state: 0x%08h, bit-%2d]", "plruModel-StateOverride-1", NWAYS, set_index, valid_ways, m_state_override_mask[i][0], m_plru_state_tracker[set_index], i), UVM_MEDIUM);
                end
            end
           `uvm_info(m_inst_name, $psprintf("[%-35s] [nWays: %2d] [set_index: 0x%08h] [validWays: 0x%08h] [state: 0x%08h -> 0x%08h]", "plruModel-StateOverride", NWAYS, set_index, valid_ways, prev_state, m_plru_state_tracker[set_index]), UVM_MEDIUM);
        end
    endfunction: compute_state_override
endclass: plru_model

`endif
