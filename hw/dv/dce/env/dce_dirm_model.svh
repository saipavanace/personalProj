////////////////////////////////////////////////////////////
//
//Behavioral model of Snoop Filters & Directory Manager
//Data Structures
//
//////////////////////////////////////////////////////////////

typedef enum bit {
    ATT_INACTIVE, ATT_ACTIVE
} att_status_t;

typedef enum bit {
    ENTRY_INVALID, ENTRY_VALID
} entry_status_t;

typedef enum bit {
    False, True
} dir_seg_status_t;

//Note: Values are hardcoded to the max limts.
//Checks are added to make sure boundaries are never crossed
//cache-line address Includes security
typedef struct {
    bit [WSMIADDR:0]  cacheline;    
    dir_seg_status_t  ownership[$];
    dir_seg_status_t  validity[$];
    entry_status_t    entry_status;
    bit               busy;
    bit               wr_pend;
} tag_snoop_filter_t;

typedef struct {
    tag_snoop_filter_t recall_entry;
    int tag_filter_id;
} recall_entry_t;

typedef struct {
    string name;
    bit filter_en;
    bit sf_hit;
    int way_allocated;
    dir_seg_status_t  ownership[$];
    dir_seg_status_t  validity[$];
} cacheline_sf_lkup_info_t;

typedef struct {
        bit        vld;
        bit [31:0] set_index; 
        int        way;
        dir_seg_status_t ownership[$];
        dir_seg_status_t validity[$];
} sf_info_t;

typedef bit [63:0] cachelines_q[$];

//maintanence recall_all members
typedef enum bit [1:0] {
    LOC_INV, LOC_TAGF, LOC_VCTB
} recall_loc_t;

//////////////////////////////////////////////////////////////
//Null Filter Class
//////////////////////////////////////////////////////////////

class null_snoop_filter extends uvm_object;

     //////////////////////////////////////////////////////////////
     //Data Members
     //////////////////////////////////////////////////////////////
     string filter_type;
     int filter_id;
     int num_assoc_agents;

     //enable debug
     bit m_dirm_dbg;

    //Handle for helper function to to generate set_indexes.
    //addr_gen_helper m_helper;
 
    `uvm_object_param_utils_begin(null_snoop_filter)
        `uvm_field_string(filter_type, UVM_DEFAULT)
        `uvm_field_int(filter_id, UVM_DEFAULT)
    `uvm_object_utils_end

     //////////////////////////////////////////////////////////////
     //Methods
     //////////////////////////////////////////////////////////////
     extern function new(string name = "null_snoop_filter");
     extern virtual function void assign_snoop_filter_type(string name = "NULL");
     extern virtual function void assign_snoop_filter_id(int id);
     extern virtual function void assign_num_cacheing_agents(int n);
     extern virtual function int get_num_cacheing_agents();
     extern virtual function string sf_segment_details(bit cacheline_valid, bit [31:0] set_index, int way = 0, bit [WSMIADDR:0] cacheline_addr = 0);
endclass: null_snoop_filter

//Constructor
function null_snoop_filter::new(string name = "null_snoop_filter");
    super.new(name);
endfunction: new

//Assign filter type
function void null_snoop_filter::assign_snoop_filter_type(string name = "NULL");
    filter_type = name;
endfunction: assign_snoop_filter_type

//Assign Snoop Filter Id
function void null_snoop_filter::assign_snoop_filter_id(int id);
    filter_id = id;
endfunction: assign_snoop_filter_id

//Assign number of cacheing agents assoc with this snoop filter
function void null_snoop_filter::assign_num_cacheing_agents(int n);
    num_assoc_agents = n;
endfunction: assign_num_cacheing_agents

//get number of caching agents assoc with this SF
function int null_snoop_filter::get_num_cacheing_agents();
    return(num_assoc_agents);
endfunction: get_num_cacheing_agents

//Return null filter details in string format
function string null_snoop_filter::sf_segment_details(bit cacheline_valid,
                                                      bit [31:0] set_index,
                                                      int way = 0,
                                                      bit [WSMIADDR:0] cacheline_addr = 0);
    string s;
    $sformat(s, "%s sf_type:%s id:%0d num_assoc_agents:%0d", s, filter_type, filter_id, num_assoc_agents);

    return(s);
endfunction: sf_segment_details

//////////////////////////////////////////////////////////////
//Tag Filter calls
//////////////////////////////////////////////////////////////
class tag_snoop_filter extends null_snoop_filter;

     //////////////////////////////////////////////////////////////
     //Data Members
     //////////////////////////////////////////////////////////////
     string tag_filter_type;

     tag_snoop_filter_t sf_cache[bit[WSFSETIDX-1:0]][$];
     int num_ways;
     tag_snoop_filter_t recall_entry;

     //Snoop Filter status (1 Enabled/0 Disabled)
     bit tag_snoop_filter_status;

     //Victim buffer 
     int victim_buffer_depth;
     tag_snoop_filter_t m_victim_buffer[$];
    
     //vb recovery
     bit en_vb_recovery;

     //Global pointers to maintian recall-all ops
     recall_loc_t recall_all_loc_in_progress;

     bit [31:0] mt_set_idx;
     int mt_way;

     //pLRU replace -> Need to keep track of state per set_index
    // bit [num_ways-2:0] index_state [bit[WSFSETIDX-1:0]]; // Need number of ways-1 bit vector per set index

     //anippuleti(12/12/16) this status signal is a hack to avoid significatnt changes to support coarse vector
     //When a entry is poped out of vctb and is allocated in tag filter, coarse vector expantion does not happen
     //In actual RTL, coarse vector expantion is done on reads to snoop filter memories. When a entry is poped
     //fro victim buffer it directly goes to ATT and write happens to assigned set_index,way on commit. Where has
     //in model poped entry is written into directory mgr and then is re-read to to forwad it on dir rsp. It works
     //in all cases but for corse vector's expansation happens when is re-read in model which is illegal. Since 
     //changing the behavior is more complex we are using a global signal to indicated on re-read that this entry
     //is from victim buffer
     bit m_pop_from_vctb;

     //Data members for cover groups (Functional Coverage)
     bit obsrvd_home_filter;
     bit obsrvd_all_ways_busy;
     bit obsrvd_tagf_hit;
     bit obsrvd_vctb_hit;
     bit obsrvd_alloc_miss;

     bit obsrvd_updreq_hit_as_owner_upd_comp;
     bit obsrvd_updreq_hit_as_sharer_upd_comp;
     bit obsrvd_updreq_miss_upd_fail;
     bit obsrvd_updreq_hit_upd_fail;
     
     bit obsrvd_recreq;
     
     bit obsrvd_vctb_not_exists;
     bit obsrvd_vctb_pop;
     bit obsrvd_vctb_full;

     bit obsrvd_vctb_recall;
     bit obsrvd_vctb_maint_recall_op;
     bit obsrvd_vctb_maint_recall_by_addr;
     bit obsrvd_vctb_updinv;
     bit obsrvd_updinv_tagf_drop4coarse_rep;
     bit obsrvd_tagf_inv_updreq;
     bit obsrvd_vctb_comp_on_updinv;
     bit obsrvd_vctb_full2empty;
     bit obsrvd_updinv_hit_coarse_rep;
     local bit log_vctb_full_once_hit;

     int obsrvd_alloc_evct_way;
     int obsrvd_hit_swap_way;

     `uvm_object_param_utils_begin(tag_snoop_filter)
         `uvm_field_int(num_ways, UVM_DEFAULT)
     `uvm_object_utils_end

     //////////////////////////////////////////////////////////////
     //Methods
     //////////////////////////////////////////////////////////////
     extern function new(string name = "tag_snoop_filter");

     //Set Methods
     extern function assign_tag_filter_type(string name);

     extern function void assign_ways(int ways);

     extern function bit [31:0] set_index_for_cacheline(bit [WSMIADDR:0] m_addr);

     extern function void assign_tag_filter_entry(bit [WSFSETIDX-1:0] set_index, int way, tag_snoop_filter_t entry);
     extern function int  get_alloc_way_vector(bit [WSFSETIDX-1:0] set_idx);
     extern function int  get_busy_way_vector(bit [WSFSETIDX-1:0] set_idx);

     extern function void assign_vctb_info(int vctb_depth);
     extern function int get_vctb_depth();

     //Snoop Filter Enable/Disable methods
     extern function bit get_snoop_filter_status();
     extern function void set_snoop_filter_status(bit status);
     extern function void flush_all_entries();

     //Printer Methods
     extern virtual function string sf_segment_details(bit cacheline_valid, bit [31:0] set_index, int way = 0, bit [WSMIADDR:0] cacheline_addr = 0);

     extern virtual function string conv_tag_info2string(bit [31:0] set_index);

     extern virtual function string conv_sf_info2string(tag_snoop_filter_t entry, input int way);

    extern function string conv_vctb_info2string();
    extern function string vctb_entry_details(int entry_idx);

     //SF Lookup functionality
     extern function bit index_collision_check(bit [31:0] set_index);

     extern function bit tag_filter_lookup(
         bit [31:0] set_index, bit [63:0] cacheline_addr,
         output int way, inout tag_snoop_filter_t entry);

     extern function bit snoop_filter_hit(bit [31:0] set_index, bit [WSMIADDR:0] cacheline_addr, inout tag_snoop_filter_t hit_entry_o, output int hit_evict_way_o, output bit vhit_o, output int vhit_idx_o);

     extern function bit entry_exists_in_tag_filter(bit [31:0] set_index, bit [WSMIADDR:0] offset_aligned_addr_w_sec, output int way);

     extern function bit entry_exists_in_victim_buffer(bit [WSMIADDR:0] offset_aligned_addr_w_sec, output int index, output bit vb_entry_moved_to_sf);

     extern function void move_vb_entry_to_sf(int vb_index, bit [WSFSETIDX-1:0] set_index, int way);
     extern function void move_recall_entry_to_vb();


     extern function bit is_index_way_valid(
         bit [31:0] set_index,
         int way);

     extern function void assign_new_info_to_reused_way(
        bit [WSFSETIDX-1:0] set_index,
        bit [WSMIADDR:0] cacheline_addr,
        int allocated_way);

     extern function void deallocate_sf_segment(
        bit [WSFSETIDX-1:0] set_index_i,
        bit [WSMIADDR:0]    offset_aligned_addr_w_sec_i,
        int                 alloc_way_i,
        bit                 eviction_needed_i);
     
     extern function void allocate_sf_segment(
        bit [WSFSETIDX-1:0] set_index_i,
        bit [WSMIADDR:0]    offset_aligned_addr_w_sec_i,
        int                 alloc_way_i,
        bit                 eviction_needed_i);

     extern function void refresh_vctb();
     
     extern function void get_possible_alloc_way_at_lookup(
         bit [WSFSETIDX-1:0]    set_index_i,
          int busy_waysq_i[$],
         output int    alloc_way_o,
         output bit    eviction_needed_o);
     
         extern function void is_set_full(
        bit [WSFSETIDX-1:0] set_index_i,
        bit print_contents,
        output bit set_full_o);

     extern function void push_recall_entry(
         bit [31:0] set_index, int way);

     extern function bit check_for_possible_vb_recovery(bit [WSFSETIDX-1:0] set_index, int way);
     //SF Commit functionality
     extern function void sf_commit(
         bit cmd_n_upd,
         bit [WSFSETIDX-1:0] set_index, int way,
          tag_snoop_filter_t commit_entry);

     extern function void reset_ownership_validity_status(
         bit [WSFSETIDX-1:0] set_index,
         int allocated_way);

     extern function int get_sf_evict_way(int recall_counter_i, inout int busy_waysq_i[$]);
     
     extern function bit sf_evict_way(
         bit [31:0] set_index,
         int recall_counter,
         output int evict_way);

     //victim buffer functionality
     extern function void victim_buffer_pop(
         int index,
         inout tag_snoop_filter_t vctb_entry);

     extern function void victim_buffer_push(
         bit[31:0] set_index,
         int evict_way);

     //anippuleti(12/10/16) coarse vector logic.
     extern function tag_snoop_filter_t expand_coarse_representation(
         tag_snoop_filter_t act_entry);
     extern function bit is_any_agent_assoc_coarse_rep_valid(
         tag_snoop_filter_t act_entry, int q[$]);
     extern function bit is_agent_assoc_coarse_vec_rep(int rel_indx_within_sf);
     extern function bit given_agent_is_presise_sharer_or_owner(bit [31:0] set_index,
         int upd_idx,
         int rel_indx_within_sf);

     //////////////////////////////////////////////////////////////
     //Metohds for seq to access directory model data
     //////////////////////////////////////////////////////////////
     extern function void get_valid_tag_filter_cachelines(int rel_indx_within_sf, inout cachelines_q m_addr_list);

     extern function void get_invalid_tag_filter_cachelines(int rel_indx_within_sf, inout cachelines_q m_addr_list);

     extern function void get_valid_victim_buffer_cachelines(int rel_indx_within_sf, inout cachelines_q m_addr_list);

     extern function void get_valid_entries_info(inout bit [WSFSETIDX-1:0] set_indexes_q[$], inout int ways_q[$], inout cachelines_q m_addr_list);

     extern function void get_invalid_entries_info(inout bit [WSFSETIDX-1:0] set_indexes_q[$], inout int ways_q[$], inout cachelines_q m_addr_list);

endclass: tag_snoop_filter 

function tag_snoop_filter::new(string name = "tag_snoop_filter");
    super.new(name);
endfunction: new

//Assign Tag Filter type
function tag_snoop_filter::assign_tag_filter_type(string name);
    tag_filter_type = name;
endfunction: assign_tag_filter_type

//Asign number of ways
function void tag_snoop_filter::assign_ways(int ways);
    this.num_ways = ways;
endfunction: assign_ways


function bit tag_snoop_filter::get_snoop_filter_status();
    return(tag_snoop_filter_status);
endfunction: get_snoop_filter_status

function void tag_snoop_filter::set_snoop_filter_status(bit status);
    tag_snoop_filter_status = status;
endfunction: set_snoop_filter_status

//#Test.DCE.MntOpDirectoryInitInvalidatesVictimBuffer
//Deleting all entries in the SF
function void tag_snoop_filter::flush_all_entries();
    bit [WSFSETIDX-1:0] set_index;

    //Tag filter flush
    do begin
        if(sf_cache.first(set_index))
            sf_cache.delete(set_index);
    end while(sf_cache.next(set_index));

    //Vcitim buffer flush
    m_victim_buffer.delete();

endfunction: flush_all_entries

//Set index for cacheline
function bit [31:0] tag_snoop_filter::set_index_for_cacheline(bit [WSMIADDR:0] m_addr);
    bit [31:0] set_index;
    set_index = ncoreConfigInfo::get_sf_set_index(filter_id, m_addr);

    /*
    // YRAMASAMY: moved away to use addrMgr code
    bit result;

    foreach(ncoreConfigInfo::sf_set_sel[filter_id].pri_bits[idx]) begin
        result = m_addr[ncoreConfigInfo::sf_set_sel[filter_id].pri_bits[idx]];
        foreach(ncoreConfigInfo::sf_set_sel[filter_id].sec_bits[idx,idx2]) begin
            result = result ^ m_addr[ncoreConfigInfo::sf_set_sel[filter_id].sec_bits[idx][idx2]];
        end
        set_index[idx] = result;
    end
    */

    return(set_index);
endfunction: set_index_for_cacheline

//****************Assign tag filter entry*******************************//
function void tag_snoop_filter::assign_tag_filter_entry(bit [WSFSETIDX-1:0] set_index, int way, tag_snoop_filter_t entry);

    sf_cache[set_index][way].cacheline      = entry.cacheline;
    sf_cache[set_index][way].entry_status   = entry.entry_status;
    sf_cache[set_index][way].busy           = entry.busy;
    for(int i = 0; i < get_num_cacheing_agents(); i++) begin
        sf_cache[set_index][way].ownership[i] = entry.ownership[i];
        sf_cache[set_index][way].validity[i]  = entry.validity[i];
    end

    if(m_dirm_dbg)
        `uvm_info("TAG SF", $psprintf("fn:assign_tag_filter_entry pkt:%s", conv_sf_info2string(sf_cache[set_index][way], way)), UVM_MEDIUM)
endfunction: assign_tag_filter_entry

//**************** Get the unalloc way vector *******************************//
function int tag_snoop_filter::get_alloc_way_vector(bit [WSFSETIDX-1:0] set_idx);
    int alloc_ways = 0;
    if(sf_cache.exists(set_idx)) begin
        foreach(sf_cache[set_idx][j]) begin
            if(sf_cache[set_idx][j].entry_status == ENTRY_VALID) begin
                alloc_ways |= (1 << j);
            end
        end
    end
    return(alloc_ways);
endfunction: get_alloc_way_vector

//**************** Get the busy way vector *******************************//
function int tag_snoop_filter::get_busy_way_vector(bit [WSFSETIDX-1:0] set_idx);
    int busy_ways = 0;
    if(sf_cache.exists(set_idx)) begin
        foreach(sf_cache[set_idx][j]) begin
            busy_ways |= (sf_cache[set_idx][j].busy << j);
        end
    end
    return(busy_ways);
endfunction: get_busy_way_vector

//****************Cacheline details in string format*******************//
function string tag_snoop_filter::sf_segment_details(bit cacheline_valid, bit [31:0] set_index, int way = 0, bit [WSMIADDR:0] cacheline_addr = 0);
    string s;

    $sformat(s, "SF Segment Details Below\n");
    $sformat(s, "%s sf_type:%s sf_id:%0d tag_type:%s num_assoc_agents:%0d set_index:0x%0h", s, filter_type, filter_id, tag_filter_type, num_assoc_agents, set_index);

    if(!cacheline_valid) begin
        $sformat(s, "%s cacheline:0x%0h entry:%s busy:%0b wr_pend:%0b", s, sf_cache[set_index][way].cacheline, sf_cache[set_index][way].entry_status, sf_cache[set_index][way].busy, sf_cache[set_index][way].wr_pend);
        $sformat(s, "%s way:%0d\n", s, way);

        for(int i = 0; i < get_num_cacheing_agents(); i++) begin
            $sformat(s, "%s cid:%0d validity:%s ownership:%s\n", s, i, sf_cache[set_index][way].validity[i].name(), sf_cache[set_index][way].ownership[i].name());
        end
    end else begin
        foreach(sf_cache[set_index,ridx]) begin 

            if(sf_cache[set_index][ridx].cacheline == cacheline_addr) begin
                $sformat(s, "%s cacheline:0x%0h entry:%s", s, sf_cache[set_index][ridx].cacheline, sf_cache[set_index][ridx].entry_status);
                $sformat(s, "%s ridx:%0d", s, ridx);

                for(int i = 0; i < get_num_cacheing_agents(); i++) begin
                    $sformat(s, "%s validity:%s ownership:%s", s, sf_cache[set_index][ridx].validity[i].name, sf_cache[set_index][ridx].ownership[i].name());
                end
            end
        end
    end
    return(s);
endfunction: sf_segment_details

function string tag_snoop_filter::conv_tag_info2string(bit [31:0] set_index);
    string s;

    if(sf_cache.exists(set_index)) begin
        $sformat(s, "\nTF%0d Entries set_index:0x%0h", filter_id, set_index);
        for(int i = 0; i < sf_cache[set_index].size(); i++)
            $sformat(s, "%s %s", s, sf_segment_details(1'b0, set_index, i));
    end
    return(s);
endfunction: conv_tag_info2string


//assign victim buffer details
function void tag_snoop_filter::assign_vctb_info(int vctb_depth);
    this.victim_buffer_depth     = vctb_depth;
endfunction: assign_vctb_info

function int tag_snoop_filter::get_vctb_depth();
    return(victim_buffer_depth);
endfunction: get_vctb_depth

//Print Snoop Filter info passed
function string tag_snoop_filter::conv_sf_info2string(
                    tag_snoop_filter_t entry,
                    input int way);
    string s;

    $sformat(s, "%s sf_type:%s id:%0d tag_type:%s assoc_agents:%0d", s, filter_type, filter_id, tag_filter_type, num_assoc_agents);

    $sformat(s, "%s cacheline:0x%0h entry:%s busy:%0b wr_pend:%0b", s, entry.cacheline, entry.entry_status, entry.busy, entry.wr_pend);
    $sformat(s, "%s way:%0d", s, way);

    for(int i = 0; i < get_num_cacheing_agents(); i++) begin
        $sformat(s, "%s validity:%s ownership:%s", s, entry.validity[i].name(), entry.ownership[i].name());
    end
    return(s);
endfunction: conv_sf_info2string

//**************************************************************************************
function string tag_snoop_filter::conv_vctb_info2string();
    string s;

    $sformat(s, "\nVB%0d Current Num Entries:%0d", filter_id, m_victim_buffer.size());
    foreach(m_victim_buffer[ridx]) begin
        $sformat(s, "%s %s", s, vctb_entry_details(ridx));
    end

    return(s);
endfunction: conv_vctb_info2string

function string tag_snoop_filter::vctb_entry_details(int entry_idx);
    string s;
    bit set_full;
    bit [WSFSETIDX-1:0] set_index = set_index_for_cacheline(m_victim_buffer[entry_idx].cacheline);
    is_set_full(set_index, 0, set_full);

    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s@ %t: id:%0d", s, $time(), filter_id);

    if(m_victim_buffer.size() > entry_idx) begin
        $sformat(s, "%s victim_buffer_entry:%0d", s, entry_idx);
        $sformat(s, "%s cacheline:0x%0h entry:%s set_index:0x%0h set_full:%0b\n", s, m_victim_buffer[entry_idx].cacheline, m_victim_buffer[entry_idx].entry_status, set_index, set_full);

        for(int i = 0; i < get_num_cacheing_agents(); i++) begin
            $sformat(s, "%s ridx:%0d validity:%s ownership:%s\n", s, i, m_victim_buffer[entry_idx].validity[i].name(), m_victim_buffer[entry_idx].ownership[i].name());
        end
    end else begin
        `uvm_fatal("TAG SF", $psprintf("Tb_Error: trying to index outof bounds size:%0d index:%0d", m_victim_buffer.size(), entry_idx))
    end
    return(s);
endfunction: vctb_entry_details

//Returns true of index match exists
function bit tag_snoop_filter::index_collision_check(bit [31:0] set_index);
    if (sf_cache.exists(set_index)) begin 
        `uvm_info("TAG SF", $psprintf("index_collision detected on sfid:%0d index:0x%0h", filter_id, set_index), UVM_MEDIUM)
    end
    return(sf_cache.exists(set_index));
endfunction: index_collision_check

//Retruns true and sets way on index & cacheline hit
//Does not modify the SF entries storage. Memory read only Method
//To update SF storage call sf_update() method.
function bit tag_snoop_filter::tag_filter_lookup(
    bit [31:0] set_index,
    bit [63:0] cacheline_addr,
    output int way,
    inout tag_snoop_filter_t entry);

    bit tmp_found;
    if((entry_exists_in_tag_filter(set_index, cacheline_addr, way)) && (sf_cache[set_index][way].entry_status == ENTRY_VALID)) begin

        entry.cacheline     = sf_cache[set_index][way].cacheline;
        entry.busy          = sf_cache[set_index][way].busy;
        entry.entry_status  = sf_cache[set_index][way].entry_status;
        for(int i = 0; i < get_num_cacheing_agents(); i++) begin
            entry.ownership[i]     = sf_cache[set_index][way].ownership[i];
            entry.validity[i]      = sf_cache[set_index][way].validity[i];
            //`uvm_info("DBG", $psprintf("fn tag_snoop_filter:tag_filter_lookup sfid: %0d cid:%0d o:%0s v:%0s", filter_id, i, entry.ownership[i], entry.validity[i]), UVM_MEDIUM)
        end

        if(m_dirm_dbg)
            `uvm_info("TAG SF", $psprintf("fn:tag_filter_lookup lookup details prior coarse expantion: %s", sf_segment_details(1'b0, set_index, way)), UVM_MEDIUM)

        //If entry is poped from vctb then do no expand coarse representation and
        //reset the status
        //TODO: Hema will ask Abhinav what this coarse represenation means?
//        if(!m_pop_from_vctb)
//            entry = expand_coarse_representation(entry);
//        else 
//            m_pop_from_vctb = 1'b0;
//        
//        if(m_dirm_dbg && m_pop_from_vctb)
//            `uvm_info("TAG SF", $psprintf("lookup details after coarse expantion: %s", conv_sf_info2string(entry, way)), UVM_MEDIUM)

        tmp_found = 1'b1;
    end
    return(tmp_found);
endfunction: tag_filter_lookup

//anippuleti(12/09/16) Ncore2.0 functionality
//Coarse vector support
//Method gets the actual tag_snoop_filter_t and returns the coarsed repersentation.
//#Check.DCE.CoarseSFVectorsAreCorrect
//FIXME TODO: Check with Abhinav if this needed for ncore 3.0
function tag_snoop_filter_t tag_snoop_filter::expand_coarse_representation(
    tag_snoop_filter_t act_entry);
    ncoreConfigInfo::int2dq coarse_vec_rep;

    // Removed get_coarse_vec_rep from addr_mgr, the function only had an error message.
    //coarse_vec_rep = ncoreConfigInfo::get_coarse_vec_rep(filter_id);
    foreach(coarse_vec_rep[idx1]) begin
        if(coarse_vec_rep[idx1].size() > 1) begin
//            if(is_any_agent_assoc_coarse_rep_valid(act_entry, coarse_vec_rep[idx1])) begin
//                int rel_indx_within_sf;
//                foreach(coarse_vec_rep[idx1][idx2]) begin
//                    rel_indx_within_sf = ncoreConfigInfo::rel_indx_within_sf(filter_id,
//                                             coarse_vec_rep[idx1][idx2]);
//                    act_entry.validity[rel_indx_within_sf] = Uncertain;
//                end
//            end
//            if(is_any_agent_assoc_coarse_rep_valid(act_entry, coarse_vec_rep[idx1]) &&
//               tag_filter_type == "PRESENCEVECTOR") begin
//                int rel_indx_within_sf;
//                foreach(coarse_vec_rep[idx1][idx2]) begin
//                    rel_indx_within_sf = ncoreConfigInfo::rel_indx_within_sf(filter_id,
//                                             coarse_vec_rep[idx1][idx2]);
//                    act_entry.ownership[rel_indx_within_sf] = Uncertain;
//                end
//            end
        end
    end
    return(act_entry);
endfunction: expand_coarse_representation

//Method returns true if any of cacheing agents is true
//CONC-2549: For a given agent in EOS filter if ownership is True then its corresponding
//           slv bit is set to 0. Hence we now check if ownserhip != True 
function bit tag_snoop_filter::is_any_agent_assoc_coarse_rep_valid(
    tag_snoop_filter_t act_entry, int q[$]);
    bit status;

//    foreach(q[idx]) begin
//       int rel_indx_within_sf;
//       rel_indx_within_sf = ncoreConfigInfo::rel_indx_within_sf(filter_id, q[idx]);
//       status = ((act_entry.ownership[rel_indx_within_sf] != True) && (act_entry.validity[rel_indx_within_sf] == True ||
//                 act_entry.validity[rel_indx_within_sf] == Uncertain)) ? 1'b1 : status;
//    end

    return(status);
endfunction: is_any_agent_assoc_coarse_rep_valid

//Method returns true if relative index of the caching  agent in SF is associated to 
//coarse representation
function bit tag_snoop_filter::is_agent_assoc_coarse_vec_rep(
    int rel_indx_within_sf);
    ncoreConfigInfo::int2dq coarse_vec_rep;
    bit status;
    int calc_indx;

    // Removed get_coarse_vec_rep from addr_mgr, the function only had an error message.
    //coarse_vec_rep = ncoreConfigInfo::get_coarse_vec_rep(filter_id);

    foreach(coarse_vec_rep[idx1]) begin
        foreach(coarse_vec_rep[idx1,idx2]) begin
            calc_indx = ncoreConfigInfo::rel_indx_within_sf(filter_id, coarse_vec_rep[idx1][idx2]);
            status = ((calc_indx == rel_indx_within_sf) && (coarse_vec_rep[idx1].size() > 1)) ?
                       1'b1 : status;
        end
    end
    return(status);
endfunction: is_agent_assoc_coarse_vec_rep

//*****************************************************
//Method returns true if cacheline exists either in snoop filter
//checks both in victim buffer && tag filter
//*****************************************************
function bit tag_snoop_filter::snoop_filter_hit(bit [31:0] set_index, 
                                                bit [WSMIADDR:0] cacheline_addr, 
                                                inout tag_snoop_filter_t hit_entry_o, 
                                                output int hit_evict_way_o, 
                                                output bit vhit_o, 
                                                output int vhit_idx_o);

    int hit_way;
    bit status;
    bit vb_entry_moved_to_sf;
   
    //clear outputs
    vhit_o = 0;
    vhit_idx_o = -1;
    hit_evict_way_o = -1;

    if (entry_exists_in_tag_filter(set_index, cacheline_addr, hit_way)) begin
        status = 1'b1;
        hit_evict_way_o = hit_way;
        hit_entry_o.cacheline     = sf_cache[set_index][hit_way].cacheline;
        hit_entry_o.busy          = sf_cache[set_index][hit_way].busy;
        hit_entry_o.wr_pend       = sf_cache[set_index][hit_way].wr_pend;
        hit_entry_o.entry_status  = sf_cache[set_index][hit_way].entry_status;
        for(int i = 0; i < get_num_cacheing_agents(); i++) begin
            hit_entry_o.ownership[i] = sf_cache[set_index][hit_way].ownership[i];
            hit_entry_o.validity[i]  = sf_cache[set_index][hit_way].validity[i];
        end
       `uvm_info("TAG SF", $psprintf("fn:snoop_filter_hit--tag_hit lookup details: %s", sf_segment_details(1'b0, set_index, hit_way)), UVM_HIGH)
        
        //For coverage
        //obsrvd_tagf_hit = 1'b1;
    end 

    if (entry_exists_in_victim_buffer(cacheline_addr, vhit_idx_o, vb_entry_moved_to_sf)) begin
        status = 1;
        vhit_o = 1;
        hit_evict_way_o = -1;
        hit_entry_o.cacheline     = m_victim_buffer[vhit_idx_o].cacheline;
        hit_entry_o.busy          = m_victim_buffer[vhit_idx_o].busy;
        hit_entry_o.entry_status  = m_victim_buffer[vhit_idx_o].entry_status;
        for(int i = 0; i < get_num_cacheing_agents(); i++) begin
            hit_entry_o.ownership[i] = m_victim_buffer[vhit_idx_o].ownership[i];
            hit_entry_o.validity[i]  = m_victim_buffer[vhit_idx_o].validity[i];
        end
       `uvm_info("TAG SF", $psprintf("fn:snoop_filter_hit--vb_hit vb_hit_idx:%0d lookup details: %s", vhit_idx_o, conv_sf_info2string(hit_entry_o, -1)), UVM_HIGH)
        
        if(sf_cache[set_index].size() != num_ways)
            `uvm_error("TAG SF", $psprintf("How is VB hit possible with set_index:0x%0h not full? num_entries_in_set:%0d num_ways:%0d", set_index, sf_cache[set_index].size(), num_ways))
    end 
    
    if ((recall_entry.entry_status == ENTRY_VALID) && (recall_entry.cacheline == cacheline_addr)) begin

       `uvm_info("DIRM MGR", "vb_hit due to entry matched in recall flop", UVM_HIGH)
        
        status = 1;
        vhit_o = 1;
        vhit_idx_o = -1; 
        hit_evict_way_o = -1;
        hit_entry_o.cacheline     = recall_entry.cacheline;
        hit_entry_o.entry_status  = recall_entry.entry_status;
        for(int i = 0; i < get_num_cacheing_agents(); i++) begin
            hit_entry_o.ownership[i] = recall_entry.ownership[i];
            hit_entry_o.validity[i]  = recall_entry.validity[i];
        end

        if(m_dirm_dbg)
            `uvm_info("TAG SF", $psprintf("fn:snoop_filter_hit--vb-hit due to recall-flop lookup details: %s", conv_sf_info2string(hit_entry_o, -1)), UVM_MEDIUM)

    end

    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", $psprintf("SFID:%0d hit_status:%b", filter_id, status), UVM_MEDIUM)
    
    return(status);
endfunction: snoop_filter_hit

//************************************************************************************
//Method returns status if entry exists in tag filter. If exists set the way
//************************************************************************************
function bit tag_snoop_filter::entry_exists_in_tag_filter( bit[31:0] set_index, bit [WSMIADDR:0] offset_aligned_addr_w_sec, output int way);
    
    bit tmp_found = 0;
    //`uvm_info("TAG SF DBG", $psprintf("set_index:0x%0h addr:0x%0h", set_index, offset_aligned_addr_w_sec), UVM_MEDIUM)
    if(sf_cache.exists(set_index)) begin
        foreach(sf_cache[set_index,ridx]) begin
            if((sf_cache[set_index][ridx].cacheline == offset_aligned_addr_w_sec) && (sf_cache[set_index][ridx].entry_status == ENTRY_VALID)) begin
                tmp_found = 1;
                way = ridx;
                break;
            end
        end
    end
    return(tmp_found);
endfunction: entry_exists_in_tag_filter

//*******************************************************************************************************
//Method returns status if entry exists in victim buffer.
//If exists, specifies the entry index in victim buffer
//*******************************************************************************************************
function bit tag_snoop_filter::entry_exists_in_victim_buffer(bit [WSMIADDR:0] offset_aligned_addr_w_sec, output int index, output bit vb_entry_moved_to_sf);

    bit tmp_found;
    vb_entry_moved_to_sf = 1'b0;
    foreach(m_victim_buffer[ridx]) begin
       `uvm_info(get_name(), $psprintf("[%-35s] [#entries: %2d] [setIdx: 0x%08h] [addr: 0x%016h] [status: %15s] [owner: %p] [sharer: %p]", "DirModel-VictimBufferContents", m_victim_buffer.size(), ridx, m_victim_buffer[ridx].cacheline, m_victim_buffer[ridx].entry_status.name(), m_victim_buffer[ridx].ownership, m_victim_buffer[ridx].validity), UVM_HIGH);
        if(m_victim_buffer[ridx].cacheline == offset_aligned_addr_w_sec) begin
            tmp_found = 1'b1;
            index     = ridx;
        end
    end


    // Check that for VB_Hit there should be no Invalid entry in Snoop Filter
    // TODO: uncomment below code when VB recovery mechanism is enabled.
//    if(tmp_found && sf_cache.exists(set_index)) begin
//        foreach(sf_cache[set_index,ridx]) begin
//            if((sf_cache[set_index][ridx].entry_status == ENTRY_INVALID) && (sf_cache[set_index][ridx].att_status == ATT_INACTIVE)) begin
//                if(m_dirm_dbg)
//                    `uvm_info("TAG SF", $psprintf("fn:entry_exists_in_victim_buffer Getting VB_hit(dirm_model) even when Snoop Filter has invalid entry : %s", sf_segment_details(1'b0, set_index, ridx)),UVM_MEDIUM)
//                // TB (Dirm_Model) needs to move the entry from VB to SF , as the same is done by the DM RTL when the CONFIG[18] register bit is set.
//                move_vb_entry_to_sf(index, set_index, ridx); // Requires (1)Index of VB entry to move, (2) Set_index of current SF, (3) way of current SF
//                tmp_found = 1'b0; // No Vb_hit will be reported as the entry in VB is moved to SF
//                vb_entry_moved_to_sf = 1'b1;
//                break;
//            end
//        end
//    end
    
    return(tmp_found);
endfunction: entry_exists_in_victim_buffer

// On getting VB_hit even when Snoop Filter has invalid entry present, 
// TB (Dirm_Model) needs to move the entry from VB to SF , as the same is done by the DM RTL when the CONFIG[18] register bit is set.
// Function requires three arguments (1)Index of VB entry to move, (2) Set_index of current SF, (3) way of current SF
function void tag_snoop_filter::move_vb_entry_to_sf(
    int vb_index,
    bit [WSFSETIDX-1:0] set_index,
    int way);

    if(sf_cache.exists(set_index)) begin
        assign_tag_filter_entry(set_index, way, m_victim_buffer[vb_index]);
        m_victim_buffer.delete(vb_index);
    end
endfunction: move_vb_entry_to_sf

function void tag_snoop_filter::move_recall_entry_to_vb();
 //   tag_snoop_filter_t vctb_entry;

 //   vctb_entry.cacheline    = sf_cache[set_index][evict_way].cacheline;
 //   vctb_entry.busy   = sf_cache[set_index][evict_way].busy;
 //   vctb_entry.entry_status = sf_cache[set_index][evict_way].entry_status;

 //   for(int i = 0; i < get_num_cacheing_agents(); i++) begin
 //       vctb_entry.ownership[i] = sf_cache[set_index][evict_way].ownership[i];
 //       vctb_entry.validity[i]  = sf_cache[set_index][evict_way].validity[i];
 //   end

    if(recall_entry.entry_status == ENTRY_VALID) begin
        m_victim_buffer.push_back(recall_entry);
        recall_entry.entry_status = ENTRY_INVALID;  
    end
endfunction: move_recall_entry_to_vb

//Method returns true if entry is valid
function bit tag_snoop_filter::is_index_way_valid(
    bit [31:0] set_index,
    int way);
    bit status;

    if(sf_cache.exists(set_index)) begin
        if(sf_cache[set_index][way].entry_status == ENTRY_VALID)
            status = 1'b1;
    end
    return(status);
endfunction: is_index_way_valid

//anippuleti(25/01/17) this method result makes sense only if it is EOS filter
//CONC-2650
//Method returns True if one of the following is meet.
//Cond1: Requestor is the Owner
//Cond2: Requestor is coarsed with only other agent and is poosible to determine presise sharer
//       (i.e the other agent is the owner)
//Cond3: Requestor is not Coarsed with any other agnet
//#Check.DCE.PreciseOwnerOrSharerInCoarseSF
function bit tag_snoop_filter::given_agent_is_presise_sharer_or_owner(
    bit [31:0] set_index,
    int upd_idx,
    int rel_indx_within_sf);
    bit status;
    ncoreConfigInfo::int2dq coarse_vec_rep;

    if(sf_cache[set_index][upd_idx].ownership[rel_indx_within_sf] == True) begin
        status = 1'b1;

    end else if(is_agent_assoc_coarse_vec_rep(rel_indx_within_sf)) begin
        int calc_indx, other_coarsed_agent_rel_indx;

        // Removed get_coarse_vec_rep from addr_mgr, the function only had an error message.
        //coarse_vec_rep = ncoreConfigInfo::get_coarse_vec_rep(filter_id); 
        foreach(coarse_vec_rep[idx1]) begin
            foreach(coarse_vec_rep[idx1,idx2]) begin
                calc_indx = ncoreConfigInfo::rel_indx_within_sf(filter_id, coarse_vec_rep[idx1][idx2]);

                //Enters into below loop only once because rel_indx_within_sf values is const 
                if((calc_indx == rel_indx_within_sf) && (coarse_vec_rep[idx1].size() == 2)) begin
                    other_coarsed_agent_rel_indx = !idx2;
                    status = sf_cache[set_index][upd_idx].ownership[
                                 ncoreConfigInfo::rel_indx_within_sf(filter_id,
                                     coarse_vec_rep[idx1][other_coarsed_agent_rel_indx])] == True ? 1'b1 : 1'b0;
                end
            end
        end
    end else begin
        status = 1'b1;
    end
    return(status);
endfunction: given_agent_is_presise_sharer_or_owner

//************************************************************************
function void tag_snoop_filter::get_possible_alloc_way_at_lookup (
    bit [WSFSETIDX-1:0]       set_index_i,
     int busy_waysq_i[$],
    output int    alloc_way_o,
    output bit    eviction_needed_o);

    bit found;
    int chk = 0;
    string msg;

    //check whether the set_index already exists in SF
    if (sf_cache.exists(set_index_i)) begin
        
        if(m_dirm_dbg)
            `uvm_info("TAG SF", $psprintf("fn:get_alloc_way existing set_index:0x%0h in sfid: %0d", set_index_i, filter_id), UVM_MEDIUM)

        if (sf_cache[set_index_i].size() > num_ways) 
            `uvm_error("TAG SF", $psprintf("Number of entries(%0d) in for set_index(0x%0h) are  > num_ways(%0d)", sf_cache[set_index_i].size(), set_index_i, num_ways))

        for(int widx = 0; widx < sf_cache[set_index_i].size(); widx++) begin
            if ((sf_cache[set_index_i][widx].entry_status == ENTRY_INVALID) && !(widx inside {busy_waysq_i})) begin
                found       = 1'b1;
                alloc_way_o = widx;

                if(m_dirm_dbg)
                    `uvm_info("TAG SF", $psprintf("found invalid way:%0d in an existing set_index:0x%0h in sfid: %0d", widx, set_index_i, filter_id), UVM_MEDIUM)
                break;
            end 
        end 
        
        //none of the existing ways are invalid
        if (found == 0) begin
            if(m_dirm_dbg)
                `uvm_info("TAG SF", $psprintf("fn:get_alloc_way existing set_index:0x%0h in sfid: %0d is full", set_index_i, filter_id), UVM_MEDIUM)
            if (sf_cache[set_index_i].size() < num_ways) begin
                alloc_way_o = sf_cache[set_index_i].size();
            end else begin //all ways full
                alloc_way_o = 0;
                if (alloc_way_o inside {busy_waysq_i}) begin
                    do 
                        begin
                            alloc_way_o++;
                            if (alloc_way_o == num_ways) begin
                                alloc_way_o = 0;
                                //`uvm_error("TAG SF", "We cannot have all ways busy and get here")
                            end
                        end
                    while (alloc_way_o inside {busy_waysq_i}); 
                end
                eviction_needed_o = 1;
            end 
        end

    end 
    //it is the 1st access to that particular set_index
    else begin
        if (m_dirm_dbg)
            `uvm_info("TAG SF", $psprintf("fn:get_alloc_way 1st access to set_index:0x%0h in sfid: %0d", set_index_i, filter_id), UVM_MEDIUM)
        alloc_way_o = 0;
        if (alloc_way_o inside {busy_waysq_i}) begin
            do 
                begin
                    alloc_way_o++;
                    if (alloc_way_o == num_ways) begin
                        alloc_way_o = 0;
                        //`uvm_error("TAG SF", "We cannot have all ways busy and get here")
                    end
                end
            while (alloc_way_o inside {busy_waysq_i}); 
        end
    end 

endfunction: get_possible_alloc_way_at_lookup

//***************************************************************
function void tag_snoop_filter::is_set_full(
        bit [WSFSETIDX-1:0] set_index_i,
        bit print_contents,
        output bit set_full_o);
    
    int num_valid_ways = 0;
    
    //print contents
    for(int widx = 0; widx < sf_cache[set_index_i].size(); widx++) begin
        if (sf_cache[set_index_i][widx].entry_status == ENTRY_VALID) begin
            num_valid_ways++;
            if(m_dirm_dbg & print_contents)
                `uvm_info("TAG SF", $psprintf("%0s", conv_sf_info2string(sf_cache[set_index_i][widx], widx)), UVM_MEDIUM)
        end 
    end
    if (num_valid_ways == num_ways)
        set_full_o = 1;
    else 
        set_full_o = 0;
    
    if(m_dirm_dbg & print_contents)
        `uvm_info("TAG SF", $psprintf("fn:is_set_full sfid:%0d, num_valid_ways:%0d num_ways: %0d set_full:%0b", filter_id, num_valid_ways, num_ways, set_full_o), UVM_MEDIUM)

endfunction: is_set_full

//***************************************************************
function void tag_snoop_filter::allocate_sf_segment(
        bit [WSFSETIDX-1:0] set_index_i,
        bit [WSMIADDR:0]    offset_aligned_addr_w_sec_i,
        int                 alloc_way_i,
        bit                 eviction_needed_i);

        tag_snoop_filter_t store_entry;
        tag_snoop_filter_t dummy_entry;
        bit entry_valid, full;
        string addr_str;

        store_entry.cacheline    = offset_aligned_addr_w_sec_i;
        store_entry.busy         = 1;
        store_entry.wr_pend      = 1;
        store_entry.entry_status = ENTRY_VALID;

        if (eviction_needed_i == 1) begin //eviction needed
            //for coverage
            if (sf_cache[set_index_i].size() != num_ways) begin
                $stacktrace();
               `uvm_error("TAG SF", $psprintf("eviction_needed:%0d size:%0d num_ways:%0d", eviction_needed_i, sf_cache[set_index_i].size(), num_ways))
            end

            if (get_vctb_depth() > 0) begin //VB exists 
               `uvm_info("TAG SF", $psprintf("VB%0d DEPTH:%0d %s", filter_id, get_vctb_depth(), conv_vctb_info2string()), UVM_HIGH);
                // Parse the Victim Buffer and move entries whose set_index has invalid and no_busy way
                // TODO: Uncomment below code when VB recovery is enabled.
                
                refresh_vctb();
 
                if(m_victim_buffer.size() == get_vctb_depth()) begin //VB is full
                    
                    //for coverage
                    obsrvd_vctb_full = 1;
                    obsrvd_vctb_pop  = 1;

                    //Entry about to recall
                    full = 1;
                    addr_str = "";
                    if (recall_entry.entry_status == ENTRY_VALID) begin 
                        if (sf_cache[set_index_i].size() != num_ways)
                            `uvm_error("TAG SF", $psprintf("if recall_entry is valid, set should have been full sfid:%0d set_index:0x%0h set.size:%0d num_ways:%0d", filter_id, set_index_i, sf_cache[set_index_i].size(), num_ways))
                        $sformat(addr_str, "%0s set_index:0x%0h ", addr_str, set_index_i);
                        foreach(sf_cache[set_index_i][way_idx]) begin
                            if (sf_cache[set_index_i][way_idx].entry_status != ENTRY_VALID) begin
                                full = 0;
                                //break;
                            end else begin 
                                $sformat(addr_str, "%0s way_%0d:%0p", addr_str, way_idx, sf_cache[set_index_i][way_idx].cacheline);
                            end
                        end
                        if ((get_vctb_depth() > 0) && (m_victim_buffer.size() != get_vctb_depth())) //VB exists and not full
                            `uvm_error("TAG SF", $psprintf("if recall_entry is valid, VB should have been full sfid:%0d VBdepth:%0d VBsize:%0d ", filter_id, get_vctb_depth(), m_victim_buffer.size()))
                        foreach(m_victim_buffer[vb_idx]) begin
                            if (m_victim_buffer[vb_idx].entry_status != ENTRY_VALID) begin
                                full = 0;
                                //break;
                            end else begin 
                                $sformat(addr_str, "%0s vbidx_%0d:%0p", addr_str, vb_idx, m_victim_buffer[vb_idx].cacheline);
                            end
                        end
                        $sformat(addr_str, "%0s recall_entry_addr:%0p", addr_str, recall_entry.cacheline);
                        `uvm_info("TAG SF", $psprintf("sfid:%0d full:%0b\n %0s", filter_id, full, addr_str), UVM_MEDIUM)
                    end
                    victim_buffer_pop((get_vctb_depth() - 1), recall_entry);
                    victim_buffer_push(set_index_i, alloc_way_i);
                    assign_new_info_to_reused_way(set_index_i, offset_aligned_addr_w_sec_i, alloc_way_i);
                    if(m_dirm_dbg)
                        `uvm_info("TAG SF", $psprintf("recall pkt:%s", conv_sf_info2string(recall_entry, alloc_way_i)), UVM_MEDIUM)

                    if(m_dirm_dbg)
                        `uvm_info("VB SF", $psprintf("After VB pop and push VB%0d %s", filter_id, conv_vctb_info2string()), UVM_MEDIUM);
                end else begin //VB is not full
                    
                    victim_buffer_push(set_index_i, alloc_way_i);
                    if(m_dirm_dbg)
                        `uvm_info("VB SF", $psprintf("After VB push only VB%0d %s", filter_id, conv_vctb_info2string()), UVM_MEDIUM);
                    assign_new_info_to_reused_way(set_index_i, offset_aligned_addr_w_sec_i, alloc_way_i);
                end
            end else begin //VB does not exists
                obsrvd_vctb_not_exists = 1;
                push_recall_entry(set_index_i, alloc_way_i);
                assign_new_info_to_reused_way(set_index_i, offset_aligned_addr_w_sec_i, alloc_way_i);
                if(m_dirm_dbg)
                    `uvm_info("TAG SF", $psprintf("No victim buffer recall pkt:%s", conv_sf_info2string(recall_entry, alloc_way_i)), UVM_MEDIUM)
            end
        end else begin //eviction not needed 
        if (sf_cache.exists(set_index_i)) begin
            if (sf_cache[set_index_i].size() > alloc_way_i) begin

                //check if the allocation is happening in an already valid entry, but without an eviction. This will lead to dm model corruptiom
                entry_valid = 0;
                for(int i = 0; i < get_num_cacheing_agents(); i++) begin
                    if (sf_cache[set_index_i][alloc_way_i].ownership[i] || sf_cache[set_index_i][alloc_way_i].validity[i]) begin
                        entry_valid = 1;
                        break;
                    end
                end
                if (entry_valid) begin
                    allocate_sf_segment(set_index_i, offset_aligned_addr_w_sec_i, alloc_way_i, 1);
                end 
                    sf_cache[set_index_i][alloc_way_i].cacheline    = store_entry.cacheline;
                    sf_cache[set_index_i][alloc_way_i].busy         = store_entry.busy;
                    sf_cache[set_index_i][alloc_way_i].entry_status = store_entry.entry_status;
            end
            else begin
                    for (int i = sf_cache[set_index_i].size(); i < alloc_way_i; i++) begin
                        sf_cache[set_index_i].push_back(dummy_entry);
                    end
                    sf_cache[set_index_i].push_back(store_entry);
            end
        end 
        else begin 
            dummy_entry.entry_status = ENTRY_INVALID;
            //HS: Below check is no longer valid since we could allocate to non-zero way if prior ways are marked busy
            //if (alloc_way_i != 0)
            //  `uvm_error("TAG SF", $psprintf("Allocated 1st way-- alloc_way:%0d", alloc_way_i))
                
                for (int i = 0; i < alloc_way_i; i++) begin
                    sf_cache[set_index_i].push_back(dummy_entry);
                end
                
                sf_cache[set_index_i].push_back(store_entry);

                if(m_dirm_dbg)
                    `uvm_info("TAG SF", $psprintf("Allocated 1st entry in the set -- Cacheline details:%s", sf_segment_details(1'b0, set_index_i, alloc_way_i)), UVM_MEDIUM)
            end
    end 

                `uvm_info("TAG SF", $psprintf("size = %d", sf_cache[set_index_i].size()), UVM_MEDIUM)
        `uvm_info("TAG SF", $psprintf("fn: allocate_sf_segment -- Cacheline details:%s", sf_segment_details(1'b0, set_index_i, alloc_way_i)), UVM_MEDIUM)
endfunction: allocate_sf_segment

//***************************************************************
function void tag_snoop_filter::refresh_vctb();
    
    bit [WSFSETIDX-1:0] set_index;
    int invalid_way = -1;
    if (m_victim_buffer.size() > 0) begin
        for (int vb_idx = m_victim_buffer.size()-1; vb_idx >= 0; vb_idx--) begin
            if (m_victim_buffer[vb_idx].entry_status == ENTRY_VALID) begin
                set_index = set_index_for_cacheline(m_victim_buffer[vb_idx].cacheline);
                invalid_way = -1;
                if (sf_cache.exists(set_index)) begin
                    if (sf_cache[set_index].size() < num_ways)
                        `uvm_error("DM_MODEL_ERROR", $psprintf("SFID:%0d cacheline:0x%0h present in VB and set_index:0x%0h contains %0d ways < num_ways(%0d) in TF", filter_id, m_victim_buffer[vb_idx].cacheline, set_index, sf_cache[set_index].size(), num_ways));
                    for (int widx = 0; widx < sf_cache[set_index].size(); widx++) begin
                        if (sf_cache[set_index][widx].entry_status == ENTRY_INVALID) begin
                            invalid_way = widx;
                            break;
                        end
                    end
                    if (invalid_way != -1) begin
                        `uvm_info("DM_MODEl", $psprintf("refresh_vctb: SFID:%0d cacheline:0x%0h present in VB_idx:%0d and set_index:0x%0h is moved into way:%0d", filter_id, m_victim_buffer[vb_idx].cacheline, vb_idx, set_index, invalid_way), UVM_MEDIUM);
                        move_vb_entry_to_sf(vb_idx, set_index, invalid_way);
                    end
                end else begin 
                    `uvm_error("DM_MODEL_ERROR", $psprintf("SFID:%0d cacheline:0x%0h present in VB and set_index:0x%0h does not exists in TF", filter_id, m_victim_buffer[vb_idx].cacheline, set_index));
                end
            end //VB entry valid
        end//loop through all VB entries
    end else begin

        if (m_dirm_dbg)
            `uvm_info("DM_MODEL", $psprintf("fn:refresh_vctb SFID:%0d victim buffer is empty", filter_id), UVM_MEDIUM);
    end



endfunction:refresh_vctb

function void tag_snoop_filter::deallocate_sf_segment(
        bit [WSFSETIDX-1:0] set_index_i,
        bit [WSMIADDR:0]    offset_aligned_addr_w_sec_i,
        int                 alloc_way_i,
        bit                 eviction_needed_i);

        tag_snoop_filter_t store_entry;
        tag_snoop_filter_t dummy_entry;
        int                oidxq[$],vidxq[$];

        store_entry.cacheline    = offset_aligned_addr_w_sec_i;
        store_entry.busy         = 1;
        store_entry.entry_status = ENTRY_VALID;

        if (eviction_needed_i == 1) begin //eviction needed ?? NEED TO think for VBHIT
    //      if (sf_cache[set_index_i].size() != num_ways) 
    //          `uvm_error("TAG SF", $psprintf("eviction_needed:%0d size:%0d num_ways:%0d", eviction_needed_i, sf_cache[set_index_i].size(), num_ways))

    //        if (get_vctb_depth() > 0) begin //VB exists 
    //          if(m_dirm_dbg)
    //                `uvm_info("TAG SF", $psprintf("VB%0d DEPTH:%0d %s", filter_id, get_vctb_depth(), conv_vctb_info2string()), UVM_MEDIUM)
    //            if(m_victim_buffer.size() == get_vctb_depth()) begin //VB is full

    //              //Entry about to recall
    //              victim_buffer_pop((get_vctb_depth() - 1), recall_entry);
    //              victim_buffer_push(set_index_i, alloc_way_i);
    //              assign_new_info_to_reused_way(set_index_i, offset_aligned_addr_w_sec_i, alloc_way_i);
    //              if(m_dirm_dbg)
    //                  `uvm_info("TAG SF", $psprintf("recall pkt:%s", conv_sf_info2string(recall_entry, alloc_way_i)), UVM_MEDIUM)

    //              if(m_dirm_dbg)
    //                  `uvm_info("VB SF", $psprintf("After VB pop and push VB%0d %s", filter_id, conv_vctb_info2string()), UVM_MEDIUM);
    //            end else begin //VB is not full
    //                victim_buffer_push(set_index_i, alloc_way_i);
    //                if(m_dirm_dbg)
    //                    `uvm_info("VB SF", $psprintf("After VB push only VB%0d %s", filter_id, conv_vctb_info2string()), UVM_MEDIUM);
    //                assign_new_info_to_reused_way(set_index_i, offset_aligned_addr_w_sec_i, alloc_way_i);
    //            end
    //        end else begin //VB does not exists
    //            push_recall_entry(set_index_i, alloc_way_i);
    //            assign_new_info_to_reused_way(set_index_i, offset_aligned_addr_w_sec_i, alloc_way_i);
    //            if(m_dirm_dbg)
    //                `uvm_info("TAG SF", $psprintf("No victim buffer recall pkt:%s", conv_sf_info2string(recall_entry, alloc_way_i)), UVM_MEDIUM)
    //      end
        end else begin //eviction not needed 
            if (sf_cache.exists(set_index_i)) begin
                oidxq = sf_cache[set_index_i][alloc_way_i].ownership.find_index(item) with (item == True);
                vidxq = sf_cache[set_index_i][alloc_way_i].validity.find_index(item) with (item == True);
                if(sf_cache[set_index_i][alloc_way_i].cacheline    == store_entry.cacheline &&
                   sf_cache[set_index_i][alloc_way_i].busy         == store_entry.busy &&
                   sf_cache[set_index_i][alloc_way_i].entry_status == store_entry.entry_status &&
                   oidxq.size()                                    == 0                        &&
                   vidxq.size()                                    == 0 ) begin
                    sf_cache[set_index_i][alloc_way_i].entry_status = ENTRY_INVALID;
                    `uvm_info("TAG SF",$sformatf("deallocate_sf_segment: The cache entry in set_index'h:%0h Way:'h%0h de-allocated",set_index_i,alloc_way_i),UVM_MEDIUM)
                end
            end else begin 
                `uvm_error("TAG SF",$sformatf("The cache entry to de-allocate doesn't exists !!!"))
            end
        end 

endfunction: deallocate_sf_segment

function void tag_snoop_filter::assign_new_info_to_reused_way(
    bit [WSFSETIDX-1:0] set_index,
    bit [WSMIADDR:0] cacheline_addr,
    int allocated_way);

    //Assign New cacheline details
    sf_cache[set_index][allocated_way].cacheline    = cacheline_addr;
    sf_cache[set_index][allocated_way].busy         = 1;
    sf_cache[set_index][allocated_way].wr_pend      = 1;
    sf_cache[set_index][allocated_way].entry_status = ENTRY_VALID;
    reset_ownership_validity_status(set_index, allocated_way);

    if(m_dirm_dbg)
        `uvm_info("TAG SF", $psprintf("Allocated new cacheline in reused way-- Cacheline details:%s", sf_segment_details(1'b0, set_index, allocated_way)), UVM_MEDIUM)
endfunction: assign_new_info_to_reused_way

//*****************Victim buffer pop************************************
function void tag_snoop_filter::victim_buffer_pop(int index, inout tag_snoop_filter_t vctb_entry);

    if(vctb_entry.entry_status == ENTRY_VALID) begin
        `uvm_error("TAG SF", $psprintf("TB_Error unexpected call to pop from VB%0d into recall flop when recall flop is not empty: %0s", filter_id, conv_sf_info2string(vctb_entry, -1)))
        //`uvm_info("TAG SF", $psprintf("TB_Error unexpected call to pop from VB%0d into recall flop when recall flop is not empty: %0s", filter_id, conv_sf_info2string(vctb_entry, -1)), UVM_MEDIUM)
    end 

    if(m_victim_buffer.size() == 0) begin
        `uvm_error("TAG SF", "Tb_Error unexpected call to pop when thre are no entries in victim buffer")
    end
    
    if(index >= get_vctb_depth()) begin
        `uvm_error("TAG SF", $psprintf("Tb_Error victim buffer is not deep enough size:%0d index:%0d", get_vctb_depth(), index))
    end

    vctb_entry.cacheline    = m_victim_buffer[index].cacheline;
    vctb_entry.busy         = m_victim_buffer[index].busy;
    vctb_entry.entry_status = m_victim_buffer[index].entry_status;

    for(int i = 0; i < get_num_cacheing_agents(); i++) begin
        vctb_entry.ownership[i] = m_victim_buffer[index].ownership[i];
        vctb_entry.validity[i]  = m_victim_buffer[index].validity[i];
    end

    m_victim_buffer.delete(index);

    //Coverage
    if(m_victim_buffer.size() == 0) begin
        if(m_dirm_dbg)
            `uvm_info("TAG SF", "Victim buffer is empty", UVM_MEDIUM)
        obsrvd_vctb_full2empty = 1'b1 && log_vctb_full_once_hit;
    end
endfunction: victim_buffer_pop

//******************victim buffer push**************************
function void tag_snoop_filter::victim_buffer_push(bit [31:0] set_index, int evict_way);

    tag_snoop_filter_t vctb_entry;

    vctb_entry.cacheline    = sf_cache[set_index][evict_way].cacheline;
    vctb_entry.busy   = sf_cache[set_index][evict_way].busy;
    vctb_entry.entry_status = sf_cache[set_index][evict_way].entry_status;

    for(int i = 0; i < get_num_cacheing_agents(); i++) begin
        vctb_entry.ownership[i] = sf_cache[set_index][evict_way].ownership[i];
        vctb_entry.validity[i]  = sf_cache[set_index][evict_way].validity[i];
    end

   // if(m_dirm_dbg)
   //     `uvm_info("TAG SF", $psprintf("vctb push prior coarse expantion: %s",
   //         sf_segment_details(1'b0, set_index, evict_way)), UVM_MEDIUM)
   // //vctb_entry = expand_coarse_representation(vctb_entry);
    
    if(m_dirm_dbg)
        `uvm_info("TAG SF", $psprintf("vctb push: %s", conv_sf_info2string(vctb_entry, evict_way)), UVM_MEDIUM)

    m_victim_buffer.push_front(vctb_entry);

endfunction: victim_buffer_push

//Recall Entry Stored in seperate transient storage.
//1-entry deep valid only for current allocate_sf_segment() interation.
//#Test.DCE.AllFlushEntriesAreGuaranteedToBeInvalid
function void tag_snoop_filter::push_recall_entry(bit [31:0] set_index, int way);
    recall_entry.cacheline      = sf_cache[set_index][way].cacheline;
    recall_entry.busy     = sf_cache[set_index][way].busy;
    recall_entry.entry_status   = sf_cache[set_index][way].entry_status;

    for(int i = 0; i < get_num_cacheing_agents(); i++) begin
        recall_entry.ownership[i]      = sf_cache[set_index][way].ownership[i];
        recall_entry.validity[i]       = sf_cache[set_index][way].validity[i];
    end

//    if(m_dirm_dbg)
//        `uvm_info("TAG SF", $psprintf("recall details prior coarse expantion: %s",
//        sf_segment_details(1'b0, set_index, way)), UVM_MEDIUM)
//    recall_entry = expand_coarse_representation(recall_entry);
    if(m_dirm_dbg)
        `uvm_info("TAG SF", $psprintf("recall entry details: %s", conv_sf_info2string(recall_entry, way)), UVM_MEDIUM)
endfunction: push_recall_entry

function bit tag_snoop_filter::check_for_possible_vb_recovery(bit [WSFSETIDX-1:0] set_index, int way);
    int jdxq[$]; //VB index
    bit success = 0;
    if(m_dirm_dbg)
        `uvm_info("VB RECOVERY", $psprintf("sfid:%0d set_index:0x%0h way:%0d", filter_id, set_index, way), UVM_MEDIUM);
    
    if (recall_entry.entry_status == ENTRY_VALID) begin 
        if (set_index == set_index_for_cacheline(recall_entry.cacheline)) begin 
            success = 1;
            assign_tag_filter_entry(set_index, way, recall_entry);
            recall_entry.entry_status = ENTRY_INVALID;
            recall_entry.cacheline = 0;
        end
    end 
    if (m_dirm_dbg) begin 
        if (success == 1) begin
            `uvm_info("VB RECOVERY", $psprintf("recall entry recovered into set_index:0x%0h", set_index), UVM_MEDIUM);
        end else if (recall_entry.entry_status == ENTRY_VALID) begin
            `uvm_info("VB RECOVERY", $psprintf("recall entry cannot be recovered into set_index:0x%0h", set_index), UVM_MEDIUM);
        end
    end

    if (success == 0) begin
        if (m_victim_buffer.size()) begin //VB not empty
            jdxq = m_victim_buffer.find_index(item) with (set_index == set_index_for_cacheline(item.cacheline));

            if(m_dirm_dbg)
                `uvm_info("VB RECOVERY", $psprintf(" %0d no. of possible VB entries recover into set_index:0x%0h", jdxq.size(), set_index), UVM_MEDIUM);

            if (jdxq.size() > 0) begin
                success = 1; 
                assign_tag_filter_entry(set_index, way, m_victim_buffer[jdxq[0]]);
                m_victim_buffer.delete(jdxq[0]);
            end 
        end else begin 

            if(m_dirm_dbg)
                `uvm_info("VB RECOVERY", "No recovery since VB is empty", UVM_MEDIUM);
        end 
    end

    return success;

endfunction: check_for_possible_vb_recovery
//Method called on Snoop-Filter commit.
//dont_write asserted on Normal Recalls & Exclusive Monitor failures
function void tag_snoop_filter::sf_commit( bit cmd_n_upd,
                                           bit [WSFSETIDX-1:0] set_index,
                                           int way,
                                           tag_snoop_filter_t commit_entry);


     if(m_dirm_dbg) begin
        `uvm_info("TAG SF", $psprintf("sf_commit: sfid:%0d set_index:0x%0h way:%0d", filter_id, set_index, way), UVM_MEDIUM)
        `uvm_info("TAG SF", $psprintf("sf_commit: Commit entry:\n %s", conv_sf_info2string(commit_entry, way)), UVM_MEDIUM)
        `uvm_info("TAG SF", $psprintf("sf_commit: Previous entry in sf_cache before commit:\n %s", conv_sf_info2string(sf_cache[set_index][way], way)), UVM_MEDIUM)
     end 
    
    if(sf_cache[set_index][way].cacheline == commit_entry.cacheline) begin

        //TODO: disabled 04_09 need to re-enable
//      if ((cmd_n_upd == 1) && (sf_cache[set_index][way].busy == 0))
//          `uvm_error("SF COMMIT", $psprintf("sf_commit: TF:%0d set_index:0x%0h way:%0d was not marked busy in DM model when commit to that set-way was pending", filter_id, set_index, way))

        sf_cache[set_index][way].wr_pend       = 0;   //Once commit is done, way is no longer wr_pend.
        sf_cache[set_index][way].busy          = 0;   //Once commit is done, way is no longer busy.
        sf_cache[set_index][way].entry_status  = commit_entry.entry_status;
        
        for(int i = 0; i < get_num_cacheing_agents(); i++) begin
            sf_cache[set_index][way].ownership[i]     = commit_entry.ownership[i];
            sf_cache[set_index][way].validity[i]      = commit_entry.validity[i];
        end
        //if ($test$plusargs("k_csr_seq=dce_csr_dceuedr0_cfgctrl_en_vbrecovery_seq")) begin 
            if (sf_cache[set_index][way].entry_status == ENTRY_INVALID) begin
                void'(check_for_possible_vb_recovery(set_index, way));
            end 
        //end 
    end else begin
            
        `uvm_fatal("TAG SF", "Tb Error: Directory trying to commit to wrong SF index/way; Way corruption")
        //anippuleti(07/09/16) In power mgmt tests, there is possiblity that couple of 
        //attid's associated to single cacheline and a recall in sleep.
        //on completion of first attid that agent is powered down and powered up before
        //all the other prior transactions complete.Since on dirm lookup does not happen on
        //recall that came out of wake, the entry gets invalidated but sf_way_write signal 
        //goes high for that SF. Hence Tag filter might get a Commit req this far but actually
        //writing nothing to SF. Hence before we trigger failure check if entry is valid and 
        //make sure that commit request is garbage and then ignore the request. this is perfectly
        //fine
        if(is_index_way_valid(set_index, way)) begin
            `uvm_info("TAG SF", $psprintf("Unexpected Cacheline commit request: commit_entry:0x%0h",
             commit_entry.cacheline), UVM_MEDIUM)
            `uvm_info("TAG SF", $psprintf("SF Entry: %s", sf_segment_details(1'b0, set_index, way)), UVM_MEDIUM)
            `uvm_info("TAG SF", $psprintf("Directory trying to update same entry with different cacheline: %s",
             conv_sf_info2string(commit_entry, way)), UVM_MEDIUM)

            `uvm_fatal("TAG SF", "Tb Error: Directory trying to commit to wrong SF index/way; Way corruption")
        end else begin
            //For CONC-2219, the fix is that on wake drectory re-evaluates if SF is enabled. If disabled, then 
            //informs att that index/way infromation is invalid and fake commit happens. But if SF is enabled 
            //before all wake requests are cleared then the commit happens beacuse directory has no way to 
            //determine that txn went to sleep when SF is disabled. Hence to support this, in model, we discard
            //below check so that the entry gets committed once SF is enabled. This still causes issues where 
            //unallocting txns get allocated  but thats fine

            //if((commit_entry.entry_status != ENTRY_INVALID) &&
            //   (commit_entry.att_status  != ATT_INACTIVE)) begin
            //    `uvm_info("TAG SF", conv_sf_info2string(commit_entry, way), UVM_MEDIUM)
            //    `uvm_info("TAG SF", "Disacarding commit since index/way are not valid", UVM_MEDIUM)
            //    `uvm_error("TAG SF", "Trying to commit to entry that was not allocated")
            //end
        end
    end
endfunction: sf_commit


function void tag_snoop_filter::reset_ownership_validity_status(
    bit [WSFSETIDX-1:0] set_index,
    int allocated_way);

    for(int i = 0; i < get_num_cacheing_agents(); i++) begin
        sf_cache[set_index][allocated_way].ownership[i] = False;
        sf_cache[set_index][allocated_way].validity[i]  = False;
    end    

endfunction: reset_ownership_validity_status

//************************************************************************
function int tag_snoop_filter::get_sf_evict_way(int recall_counter_i, inout int busy_waysq_i[$]);

    int way_num_pick = recall_counter_i;

    while (way_num_pick inside {busy_waysq_i}) begin
        way_num_pick++;
        if (way_num_pick == num_ways) begin 
            way_num_pick = 0;
        end
    end
        
    if(m_dirm_dbg)
        `uvm_info("TAG SF", $psprintf("fn:get_sf_evict_way alloc_evict_way:%0d", way_num_pick), UVM_MEDIUM)
    return way_num_pick;

endfunction: get_sf_evict_way

//*********************************************************************
//Method decides with way to either recall (victim buffer absent) or push to victim buffer.
//*********************************************************************
function bit tag_snoop_filter::sf_evict_way(bit [31:0] set_index, int recall_counter, output int evict_way);

// TODO: Ask Abhinav what the code below is doing?
//    bit tmp_found2;
//    int seed, ball_ptr;
//
//    if(recall_counter == 0)
//        seed = sf_cache[set_index].size()-1;
//    else
//        seed = recall_counter - 1;
//   
//    ball_ptr = seed;
//    if(m_dirm_dbg)
//        `uvm_info("TAG SF", $psprintf("count:%0d ball_ptr:%0d ways_grabbed:%0d",
//            recall_counter, seed, sf_cache[set_index].size()), UVM_MEDIUM)
//    //Possibility of infinite loop
//    do begin
//        if(!cacheline_active_in_att(set_index, sf_cache[set_index][seed].cacheline)) begin
//           tmp_found2 = 1'b1;
//           evict_way = seed;
//        end else begin
//            if(seed == 0) begin
//                seed = sf_cache[set_index].size()-1;
//                if(m_dirm_dbg)
//                    `uvm_info("TAG SF", "Reached to first way, Start from last way", UVM_MEDIUM)
//            end else begin
//                seed--;
//            end
//       end
//    end while(!((seed == ball_ptr) || tmp_found2));

    //return(tmp_found2);
    return(1);
endfunction: sf_evict_way

//Get valid tag filter cachelines
function void tag_snoop_filter::get_valid_tag_filter_cachelines(
    int rel_indx_within_sf,
    inout cachelines_q m_addr_list);

    bit [WSFSETIDX-1:0] set_index;

    if(sf_cache.first(set_index)) begin

        do begin
            foreach(sf_cache[set_index,ridx]) begin
                if((sf_cache[set_index][ridx].entry_status == ENTRY_VALID) &&
                    (sf_cache[set_index][ridx].validity[rel_indx_within_sf] == True)) begin

                    m_addr_list.push_back(sf_cache[set_index][ridx].cacheline);
                end
            end
        end while(sf_cache.next(set_index));
    end
endfunction: get_valid_tag_filter_cachelines

//
function void tag_snoop_filter::get_invalid_tag_filter_cachelines(
    int rel_indx_within_sf,
    inout cachelines_q m_addr_list);

    bit [WSFSETIDX-1:0] set_index;

    if(sf_cache.first(set_index)) begin

        do begin
            foreach(sf_cache[set_index,ridx]) begin
                if((sf_cache[set_index][ridx].entry_status == ENTRY_VALID) &&
                    (sf_cache[set_index][ridx].validity[rel_indx_within_sf] == False)) begin

                    m_addr_list.push_back(sf_cache[set_index][ridx].cacheline);
                end
            end
        end while(sf_cache.next(set_index));
    end
endfunction: get_invalid_tag_filter_cachelines

function void tag_snoop_filter::get_valid_victim_buffer_cachelines(
    int rel_indx_within_sf,
    inout cachelines_q m_addr_list);

    foreach(m_victim_buffer[ridx]) begin
        if((m_victim_buffer[ridx].entry_status == ENTRY_VALID) && 
            (m_victim_buffer[ridx].validity[rel_indx_within_sf] == True)) begin

            m_addr_list.push_back(m_victim_buffer[ridx].cacheline);
        end
    end

endfunction: get_valid_victim_buffer_cachelines

//Method returns all valid entries for given SF
function void tag_snoop_filter::get_valid_entries_info(
    inout bit [WSFSETIDX-1:0] set_indexes_q[$],
    inout int ways_q[$],
    inout cachelines_q m_addr_list);

    bit [WSFSETIDX-1:0] set_index;

    if(sf_cache.first(set_index)) begin

        do begin
            foreach(sf_cache[set_index,ridx]) begin
                if(sf_cache[set_index][ridx].entry_status == ENTRY_VALID) begin
                    set_indexes_q.push_back(set_index);
                    ways_q.push_back(ridx);
                    m_addr_list.push_back(sf_cache[set_index][ridx].cacheline);
                end
            end
        end while(sf_cache.next(set_index));
    end

endfunction: get_valid_entries_info

//Method returns all entries for given SF either valid or invalid
//If you want only valid entries then call get_valid_entries_info()
//If calling this entry returns empty queues then it means that
//for given SF, there was'nt a single transaction allocated
function void tag_snoop_filter::get_invalid_entries_info(
    inout bit [WSFSETIDX-1:0] set_indexes_q[$],
    inout int ways_q[$],
    inout cachelines_q m_addr_list);

    bit [WSFSETIDX-1:0] set_index;

    if(sf_cache.first(set_index)) begin

        do begin
            foreach(sf_cache[set_index,ridx]) begin
                if(sf_cache[set_index][ridx].entry_status != ENTRY_VALID) begin
                    set_indexes_q.push_back(set_index);
                    ways_q.push_back(ridx);
                    m_addr_list.push_back(sf_cache[set_index][ridx].cacheline);
                end
            end
        end while(sf_cache.next(set_index));
    end

endfunction: get_invalid_entries_info

//////////////////////////////////////////////////////////////
//Directory Manager Behavioral model
//////////////////////////////////////////////////////////////

class directory_mgr extends uvm_object;

    `uvm_object_param_utils(directory_mgr)

    //////////////////////////////////////////////////////////////
    //Data Members
    //////////////////////////////////////////////////////////////
    
    //all SF handles
    uvm_object m_snoop_filterq[$];

    //Handle for helper function to to generate set_indexes.
    //addr_gen_helper m_helper;
    
    //Recall entry queue
    recall_entry_t recall_list[$];

    //List of all vb entries that could be recalled.
    recall_entry_t vb_list[$];
    
    //List of all tf entries that could be recalled.
    recall_entry_t tf_list[$];

    //maintanence req info
    //anippuleti (07/22/14) RTL signal maintActv stays high for entire lifetime of maint transaction
    //(CSR programmed, dirm processing, and att processing and ends finally when commit happens)
    //The same behavior is modelled with properties maint_req_in_pipeline, maint_req_pend_in_att
    //maint_req_in_progress is model equavilent of RTL maintActv. This support fixes the bug that occurs
    //if SW programs maint-op without polling mainActv bit

    bit maint_req_in_progress;
    bit maint_req_in_pipeline, maint_req_pend_in_att;
    //<%=obj.BlockId + '_con'%>::dce_maint_pkt_t maint_pkt;

    //event triggers on end lookup_request() method call to trigger
    //recall predicition method get_recall_cacheline() to maintain
    //sycronization between two processes.
    //event e_recall_predict;
    uvm_event e_recall_predict;

    //debug enable switches
    bit m_dirm_dbg;

    //vb recovery
    bit en_vb_recovery;

    //Data members for cover groups associated per directory
    bit obsrvd_vctb_hit_in_all_sf;
    bit obsrvd_tagf_hit_in_all_sf;
    bit obsrvd_vctb_hit_in_multiple_sf;
    bit obsrvd_tagf_hit_in_multiple_sf;
    bit obsrvd_vctb_hit_tagf_hit;
    bit obsrvd_alloc_miss_vb_hit;
    //per Tag_filter X cover_property
    bit m_sampleq[$][string];
    int m_alloc_evct_wayq[$];
    int m_hit_swap_wayq[$];

    //////////////////////////////////////////////////////////////
    //Methods
    //////////////////////////////////////////////////////////////
    //construction methods
    extern function new(string name = "dce_directory_mgr");
    extern function void construct_sf();
    extern function void assign_dbg_verbosity(bit level);
    //Scoreboards interface methods
    extern function int update_request(
        bit [WSMIADDR:0]    addr_w_sec_i,
        int                 iid_i,
        bit                 upd_status_comp_i);

    extern function int get_hit_way(
        bit [WSMIADDR:0]    addr_w_sec_i,
        int                 iid_i);

    extern function void commit_request(
        bit [WSMIADDR:0]                                     addr_i,
        bit [ncoreConfigInfo::NUM_CACHES-1:0]                   ocv_i,
        bit [ncoreConfigInfo::NUM_CACHES-1:0]                   scv_i,
        bit [ncoreConfigInfo::NUM_CACHES-1:0]                   change_vec_i,
        bit [WSFWAYVEC-1:0]                                  way_vec_i);

    extern function int get_waynum (int sfid_i, bit [WSFWAYVEC-1:0] way_vec_i);

    extern function void repair_model_on_hitway_mismatch(
        int                 sfid_i,
        bit [WSMIADDR:0]    addr_w_sec_i,
        bit [WSFWAYVEC-1:0] way_vec_i);
    extern function void repair_model_on_vbhit_mismatch(
        int                 sfid_i,
        bit [WSMIADDR:0]    addr_w_sec_i,
        bit [WSFWAYVEC-1:0] way_vec_i);

    extern function void check_dm_lkprsp_swap_way_on_vbhit(bit [WSFWAYVEC-1:0] way_vec_i, bit [ncoreConfigInfo::NUM_SF-1:0] vbhit_sfvec_i);

    extern function void update_model_for_allocating_request_or_vhit(
        int                 sfid_i,
        bit [WSMIADDR:0]    addr_w_sec_i,
        bit [WSFWAYVEC-1:0] way_vec_i,
        bit                 eviction_needed_i);
    
    extern function void update_model_for_deallocating_request(
        int                 sfid_i,
        bit [WSMIADDR:0]    addr_w_sec_i,
        bit [WSFWAYVEC-1:0] way_vec_i,
        bit                 eviction_needed_i);
    
    extern function void update_model(
        int                 sfid_i,
        bit                 hf_allocreq_i,
        bit [WSMIADDR:0]    addr_w_sec_i,
        bit [WSFWAYVEC-1:0] way_vec_i,
        bit                 wr_required_i);
   
    extern function void check_busy_waysq( int q[$], int sfid, bit [WSFSETIDX-1 : 0] set_index);
    extern function void clear_busy_on_attid_dealloc(bit [WSMIADDR:0] addr_w_sec_i);

    extern function void lookup_request(
        bit [WSMIADDR:0]                          addr_w_sec_i,
        int                                       iid_i,
        bit                                       alloc_i,
        bit [$clog2(ncoreConfigInfo::NUM_SF)-1:0]    filter_num_i,
        bit [WSFWAYVEC-1:0]                       busy_vec_tm_i,
        bit [WSFWAYVEC-1:0]                       busy_vec_dm_i,
        bit [WSFWAYVEC-1:0]                       pipelined_req_vec_i,
        output bit [ncoreConfigInfo::NUM_CACHES-1:0] olv_o,
        output bit [ncoreConfigInfo::NUM_CACHES-1:0] slv_o,
        output bit [WSFWAYVEC-1:0]                way_vec_o,
        output bit [ncoreConfigInfo::NUM_SF-1:0]     eviction_needed_sfvec_o,
        inout int                                   evict_wayq_o[$],
        output bit [ncoreConfigInfo::NUM_SF-1:0]     vbhit_sfvec_o,
        output bit [ncoreConfigInfo::NUM_SF-1:0]     tfhit_sfvec_o,
        inout int                                   hit_wayq_o[$]);

    //Display metohods for debugging
    extern function void print_all_ways(bit [WSMIADDR:0] m_cacheline);
    extern function void print_exp_recall_entry();

    //Helper Methods
    extern function void flush_all_entries(int sfid);
    extern function void dirm_sfen_reg_status(bit [31:0] sf_status);
    extern function void sf_disable_on_uncorr_err(bit [31:0] sf_disable);
    extern function void populate_vb_list();
    extern function void populate_recall_list();
    extern function void populate_tf_list(bit [WSMIADDR:0] addr_w_sec_i);
    extern function void delete_entry_in_vb(bit [WSMIADDR:0] cacheline_addr, int sfid);
    extern function void delete_entry_in_tf(bit [WSMIADDR:0] cacheline_addr, int sfid);
    extern function void get_busy_ways( bit [WSFWAYVEC-1:0] busy_vec_i, 
                                        int        sfid_i,
                                        inout int    busy_waysq_o[$] );
    extern function void revert_model_on_retryrsp(bit [WSMIADDR : 0] cacheline, int sfid);
    extern function void construct_lookup_vectors( sf_info_t                        sf_info_i[$],
                                                  output bit [ncoreConfigInfo::NUM_CACHES-1:0] olv_o,  
                                                  output bit [ncoreConfigInfo::NUM_CACHES-1:0] slv_o, 
                                                  output bit [WSFWAYVEC-1:0]                way_vec_o);

    extern function bit is_snoop_filter_en(int id);
    extern function bit addr_hit_in_tag_filter(
        bit [WSMIADDR:0] offset_aligned_addr_w_sec,
        int m_sfid,
        output int way_alloc,
        inout tag_snoop_filter_t m_lkup);

    extern function int count_bits(bit [31:0] val);
    extern function bit [WSMIADDR:0] offset_align_cacheline(bit [WSMIADDR:0] m_addr_w_sec);

    extern function bit [31:0] set_index_for_cacheline(bit [WSMIADDR:0] m_addr, int m_sfid);
    
    extern function tag_snoop_filter get_tag_sf_handle(int m_sfid);

    extern function bit sf_entry_validity(
        bit [ncoreConfigInfo::NUM_CACHES-1:0] m_ocv,
        bit [ncoreConfigInfo::NUM_CACHES-1:0] m_scv,
        int sidx,
         int assoc_cacheids[$]);

    //Commit & Lookup vector construction & decoding methods
    //Owner/Sharer vector calculation methods
    extern function void assign_ownership_validity_status(
        int sfid_i,
        int cacheid_i,
        bit [ncoreConfigInfo::NUM_CACHES-1:0] ocv_i,
        bit [ncoreConfigInfo::NUM_CACHES-1:0] scv_i,
        output dir_seg_status_t ownership_o,
        output dir_seg_status_t validity_o);

    extern function bit eos_filter_exists(
         cacheline_sf_lkup_info_t m_sf_lkup_info[$]);

    extern function void assign_eos_lkup_vectors(
        int m_sfid,
        cacheline_sf_lkup_info_t m_lkup_info,
        inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv,
        inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_slv);

    extern function void assign_pv_lkup_vectors(
        int m_sfid,
        bit owner_exists,
        cacheline_sf_lkup_info_t m_lkup_info,
        inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv,
        inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_slv);

    extern function void assign_null_lkup_vectors(
        int m_sfid,
        bit owner_exists,
        cacheline_sf_lkup_info_t m_lkup_info,
        inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv,
        inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_slv);

    extern function bit potential_owner_exists(
         bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv);

    extern function void extract_sf_hit_miss_info(
        bit [WSMIADDR:0] offset_aligned_addr_w_sec,
        inout cacheline_sf_lkup_info_t sf_lkup_info[$]);

     //////////////////////////////////////////////////////////////
     //Methods for seq to acesses Direcory mgr cachelines
     //////////////////////////////////////////////////////////////
     extern function void get_reqaiu_valid_tagf_cachelines(
         int req_aiuid,
         inout cachelines_q m_addr_list);
    
     extern function void get_reqaiu_valid_vctb_cachelines(
         int req_aiuid,
         inout cachelines_q m_addr_list);

     extern function void get_reqaiu_invalid_cachelines(
         int req_aiuid,
         inout cachelines_q m_addr_list);

     extern function void get_valid_entries_info(
         int sf_id,
         inout bit [WSFSETIDX-1:0] set_indexes_q[$],
         inout int ways_q[$],
         inout cachelines_q m_addr_list);

     extern function void get_invalid_entries_info(
         int sf_id,
         inout bit [WSFSETIDX-1:0] set_indexes_q[$],
         inout int ways_q[$],
         inout cachelines_q m_addr_list);

     extern function void dm_lkprsp_checks(int home_filter,  dm_seq_item lkprsp);
     //////////////////////////////////////////////////////////////
     //Method for coverage collection
     //////////////////////////////////////////////////////////////
     extern function void dm_lkprsp_sf_coverage(int home_filter,  dm_seq_item lkprsp);
     extern function void collect_dm_coverage();
     extern function void collect_dm_rtyrsp_coverage();
     extern function void log_cov_hit(string msg, int filter_id);
     extern function void print_cov_data();

endclass: directory_mgr

//new
function directory_mgr::new(string name = "dce_directory_mgr");
    super.new(name);

    //Construct helper object
    //m_helper = new("addr_gen_helper");
    e_recall_predict = new("e_recall_predict");

    //Construct all snoop filters
    construct_sf();
endfunction: new

function void directory_mgr::construct_sf();

    `uvm_info("DIRM MGR", "Constructing snoop filters", UVM_MEDIUM)
    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        if(ncoreConfigInfo::snoop_filters_info[i].filter_type == "TAGFILTER") begin
            tag_snoop_filter m_tag_sf;

            m_tag_sf = tag_snoop_filter::type_id::create($sformatf("m_tag_sf[%0d]",m_tag_sf));
            m_tag_sf.en_vb_recovery = en_vb_recovery;
            m_tag_sf.assign_snoop_filter_type("TAGFILTER");
            m_tag_sf.assign_snoop_filter_id(i);
            m_tag_sf.assign_num_cacheing_agents(ncoreConfigInfo::get_sf_assoc_num_cache_agents(i));
            m_tag_sf.assign_tag_filter_type(ncoreConfigInfo::snoop_filters_info[i].tag_sf_type);
            m_tag_sf.assign_ways(ncoreConfigInfo::snoop_filters_info[i].num_ways);
            m_tag_sf.assign_vctb_info(ncoreConfigInfo::snoop_filters_info[i].victim_entries);
            //TODO: sf enable needs to be controlled by reg bit setting.
            m_tag_sf.set_snoop_filter_status(1'b1);
            //m_tag_sf.m_helper = m_helper;
           
            `uvm_info("DIRM MGR", $psprintf("SF[%0d] is a TAGFILTER type:%s, num_cacheing_agents:%0d, num_ways:%0d num_victim_entries:%0d",
                                     i, 
                                     ncoreConfigInfo::snoop_filters_info[i].tag_sf_type,
                                     ncoreConfigInfo::get_sf_assoc_num_cache_agents(i),
                                     ncoreConfigInfo::snoop_filters_info[i].num_ways,
                                     ncoreConfigInfo::snoop_filters_info[i].victim_entries), UVM_MEDIUM)
            m_snoop_filterq[i] = m_tag_sf;
           
        end else begin
            null_snoop_filter m_null_sf;

            if(m_dirm_dbg)
                `uvm_info("DIRM MGR", $psprintf("SF[%0d] is a NULL", i), UVM_MEDIUM)
            m_null_sf = null_snoop_filter::type_id::create($sformatf("m_null_sf[%0d]",m_null_sf));
 
            m_null_sf.assign_snoop_filter_type("TAGFILTER");
            m_null_sf.assign_snoop_filter_id(i);
            m_null_sf.assign_num_cacheing_agents(ncoreConfigInfo::get_sf_assoc_num_cache_agents(i));
            //m_null_sf.m_helper = m_helper;

            m_snoop_filterq[i] = m_null_sf;
        end
    end

endfunction: construct_sf

//Debug Verbosity
function void directory_mgr::assign_dbg_verbosity(bit level);
    tag_snoop_filter m_tag_sf;
    null_snoop_filter m_null_sf;

    m_dirm_dbg = level;

    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        if(ncoreConfigInfo::snoop_filters_info[i].filter_type == "TAGFILTER") begin
            if(!$cast(m_tag_sf, m_snoop_filterq[i]))
                `uvm_fatal("DIRM MGR", "Unable to cast")

            m_tag_sf.m_dirm_dbg = m_dirm_dbg;
        end else  begin
            if(!$cast(m_null_sf, m_snoop_filterq[i]))
                `uvm_fatal("DIRM MGR", "Unable to cast")

            m_null_sf.m_dirm_dbg = m_dirm_dbg;
        end
    end
endfunction: assign_dbg_verbosity

//Update request
function int directory_mgr::update_request(
    bit [WSMIADDR:0]    addr_w_sec_i,
    int                 iid_i,
    bit                 upd_status_comp_i);

    int                   ridx;
    int                   hit_evict_way;
    tag_snoop_filter_t    hit_entry;
    tag_snoop_filter      tag_sf;
    bit [WSFSETIDX-1 : 0] set_index;
    bit [WSMIADDR:0]      offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    int                   cacheid                   = ncoreConfigInfo::get_cache_id(iid_i);
    int                   sfid                      = ncoreConfigInfo::get_snoopfilter_id(iid_i);
    bit                   vb_hit                    = 0;
    int                   vb_hit_idx                = 0;
    bit                   none_valid                = 1;
    bit                   entry_busy                = 1;

    if ((cacheid == -1) || (sfid == -1)) begin
        `uvm_fatal("DIRM MGR", $psprintf("Unexpected update request received from non cacheing agent:%0d", iid_i))
    end

    //Update SF Ino if it is a Tag filter
    if((ncoreConfigInfo::snoop_filters_info[sfid].filter_type == "TAGFILTER") && is_snoop_filter_en(sfid)) begin

        tag_sf = get_tag_sf_handle(sfid);
        set_index = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid);

        tag_sf.snoop_filter_hit(set_index, offset_aligned_addr_w_sec, hit_entry, hit_evict_way, vb_hit, vb_hit_idx);
       `uvm_info("DIRM DBG", $psprintf("UPD_REQ SF Hit sfid:%0d offset_aligned_addr_w_sec:0x%0h set_index:0x%0h vb_hit:%0d vb_hit_idx:%0d ridx:%0d hit_entry_details:%0s", sfid, offset_aligned_addr_w_sec, set_index, vb_hit, vb_hit_idx, ridx, tag_sf.conv_sf_info2string(hit_entry, hit_evict_way)), UVM_MEDIUM)
            
        if (tag_sf.snoop_filter_hit(set_index, offset_aligned_addr_w_sec, hit_entry, hit_evict_way, vb_hit, vb_hit_idx)) begin
            
            ridx = ncoreConfigInfo::rel_indx_within_sf(sfid, cacheid);
            `uvm_info("DIRM MGR", $psprintf("UPD_REQ SF Hit sfid:%0d offset_aligned_addr_w_sec:0x%0h set_index:0x%0h vb_hit:%0d vb_hit_idx:%0d ridx:%0d hit_entry_details:%0s", sfid, offset_aligned_addr_w_sec, set_index, vb_hit, vb_hit_idx, ridx, tag_sf.conv_sf_info2string(hit_entry, hit_evict_way)), UVM_MEDIUM)

            //RTL indicates upd_status=UPD_FAIL so do not update directory, but issue a fail.
            //If an entry indicates ENTRY_VALID and all cacheing agents associated with that SF indicate validity=False, it means the entry was marked busy.
            for(int i = 0; i < tag_sf.get_num_cacheing_agents(); i++) begin
                if (hit_entry.validity[i] == True) begin
                    entry_busy = 0;
                    break;
                end
            end

            if (upd_status_comp_i == 0) begin
                tag_sf.obsrvd_updreq_hit_upd_fail = 1;
                `uvm_info("DCE DM MODEL", $psprintf("UPD_REQ status- UPD_FAIL SF Hit Entry allocated for pending write:%0d: - %0s", entry_busy, tag_sf.conv_sf_info2string(hit_entry,-1)), UVM_MEDIUM)
            end else begin //upd_status = UPD_COMP
                
                if (hit_entry.validity[ridx] == True) begin
                    if (hit_entry.ownership[ridx] == True)
                        tag_sf.obsrvd_updreq_hit_as_owner_upd_comp = 1;
                    else 
                        tag_sf.obsrvd_updreq_hit_as_sharer_upd_comp = 1;
                end 

                if (vb_hit) begin //VB HIT
                    //`uvm_info("VB SF", $psprintf("UPD_REQ_DBG VB%0d %s", sfid, tag_sf.conv_vctb_info2string()), UVM_MEDIUM);

                    if (vb_hit_idx != -1) begin
                        if(m_dirm_dbg)
                            `uvm_info("TAG SF", $psprintf("VB entry before UpdInv is processed: %s", tag_sf.vctb_entry_details(vb_hit_idx)), UVM_MEDIUM)

                        tag_sf.m_victim_buffer[vb_hit_idx].ownership[ridx] = False;
                        tag_sf.m_victim_buffer[vb_hit_idx].validity[ridx]  = False;

                        for(int i = 0; i < tag_sf.get_num_cacheing_agents(); i++) begin
                            if (tag_sf.m_victim_buffer[vb_hit_idx].validity[i] == True) begin
                                none_valid = 0;
                                break;
                            end
                        end

                        if (none_valid == 1)
                            tag_sf.m_victim_buffer[vb_hit_idx].entry_status = ENTRY_INVALID;
                        else 
                            tag_sf.m_victim_buffer[vb_hit_idx].entry_status = ENTRY_VALID;

                        if(m_dirm_dbg)
                            `uvm_info("TAG SF", $psprintf("VB entry after UpdInv is processed: %s", tag_sf.vctb_entry_details(vb_hit_idx)), UVM_MEDIUM)

                        if(tag_sf.m_victim_buffer[vb_hit_idx].entry_status == ENTRY_INVALID) begin 
                            tag_sf.m_victim_buffer.delete(vb_hit_idx);
                        end 
                    end else begin //upd_req hits in recall flop 
                        if(m_dirm_dbg)
                            `uvm_info("TAG SF", $psprintf("Recall entry before UpdInv is processed: %s", tag_sf.conv_sf_info2string(tag_sf.recall_entry, -1)), UVM_MEDIUM)
                            
                        tag_sf.recall_entry.ownership[ridx] = False;
                        tag_sf.recall_entry.validity[ridx]  = False;

                        for(int i = 0; i < tag_sf.get_num_cacheing_agents(); i++) begin
                            if (tag_sf.recall_entry.validity[i] == True) begin
                                none_valid = 0;
                                break;
                            end
                        end

                        if (none_valid == 1)
                            tag_sf.recall_entry.entry_status = ENTRY_INVALID;
                        else 
                            tag_sf.recall_entry.entry_status = ENTRY_VALID;

                        if(m_dirm_dbg)
                            `uvm_info("TAG SF", $psprintf("VB entry after UpdInv is processed: %s", tag_sf.conv_sf_info2string(tag_sf.recall_entry, -1)), UVM_MEDIUM)

                    end //upd_req hits in recall flop

                end //VB HIT
                else begin //TAG FILTER HIT
                    hit_entry.ownership[ridx] = False;
                    hit_entry.validity[ridx]  = False;

                    for(int i = 0; i < tag_sf.get_num_cacheing_agents(); i++) begin
                        if (hit_entry.validity[i] == True) begin
                            none_valid = 0;
                            break;
                        end
                    end

                    //CONC-7318
                    //An UPDreq collides with already in progress CMDreq in DM pipe, and UPDreq is allowed to complete. 
                    //It cannot just invalidate the entry, since an sf update from the CMDreq may be pending.
                    //So only mark the entry as Invalid if there is no wr_pend, since if entry is marked INVALID with a pending write, the entry could be corrupted due to VB recovery
                    if (none_valid == 1 && (hit_entry.wr_pend == 0)) begin
                        hit_entry.entry_status = ENTRY_INVALID;
                    end
                    else begin
                        hit_entry.entry_status = ENTRY_VALID;
                    end
                
                    tag_sf.sf_commit(0, set_index, hit_evict_way, hit_entry);
                end // TAG FILTER HIT
            end //upd_status == UPD_COMP
        end //snoop-filter hit
        else begin //snoop-filter miss
            if (upd_status_comp_i == 1) begin
                // CONC-13075
                // When there is no victim buffer, the scoreboard prediction of a miss is ahead of the RTL pipeline design.
                // This causes upd_status prediction to go out of sync!
                // Waiving this for 3.6 release.
                if(tag_sf.get_vctb_depth() > 0) begin
                   `uvm_error("DCE DM MODEL", $psprintf("UPD_REQ status- UPD_COMP SF Miss not possible"))
                end
            end
            tag_sf.obsrvd_updreq_miss_upd_fail = 1;
        end
    end //tag-filter && sfen==1
    return(hit_evict_way);

endfunction: update_request

function int directory_mgr::get_hit_way(
    bit [WSMIADDR:0]    addr_w_sec_i,
    int                 iid_i);

    int                   hit_way = -1;
    tag_snoop_filter      tag_sf;
    bit [WSFSETIDX-1 : 0] set_index;
    bit [WSMIADDR:0]      offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    int                   cacheid                   = ncoreConfigInfo::get_cache_id(iid_i);
    int                   sfid                      = ncoreConfigInfo::get_snoopfilter_id(iid_i);

    if((ncoreConfigInfo::snoop_filters_info[sfid].filter_type == "TAGFILTER") && is_snoop_filter_en(sfid)) begin
        tag_sf = get_tag_sf_handle(sfid);
        set_index = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid);
        tag_sf.entry_exists_in_tag_filter(set_index, offset_aligned_addr_w_sec, hit_way);
    end //tag-filter && sfen==1
    return(hit_way);
endfunction: get_hit_way 

//Method called on commits
function void directory_mgr::commit_request(
    bit [WSMIADDR:0]                                     addr_i,
    bit [ncoreConfigInfo::NUM_CACHES-1:0]                   ocv_i,
    bit [ncoreConfigInfo::NUM_CACHES-1:0]                   scv_i,
    bit [ncoreConfigInfo::NUM_CACHES-1:0]                   change_vec_i,
    bit [WSFWAYVEC-1:0]                                  way_vec_i);

    int                 cache_idsq[$];
    int                 ridx;
    bit [WSFSETIDX-1:0] set_index;
    bit [WSFWAYVEC-1:0] mask;
    int                 sf_write_en[$];
    int                 sf_write_way[$];
    int                 startBit, isolatedXbits, sf_id; 
    int                 oidxq[$],vidxq[$], prev_alloc_ways, prev_busy_ways;
    string              s;
    tag_snoop_filter    tag_sf;
    tag_snoop_filter_t  commit_entry;

//    tag_sf = get_tag_sf_handle(0);
//    set_index = 'h12;
//  if (tag_sf.sf_cache.exists(set_index)) begin
//      foreach (tag_sf.sf_cache[set_index][way_idx]) begin  //loop through all ways in set, and check if busy ways are matched with RTL busy_vec.
//          `uvm_info("CMT_REQ TAG SF0 DATA", $psprintf("set_index:0x%0h %0s", set_index, tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][way_idx], way_idx)), UVM_MEDIUM)
//      end
//  end

    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        sf_write_en[i] = 0;
        sf_write_way[i] = 0;
    end
            
    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", $psprintf("fn:commit_request ocv:0x%0h osv:0x%0h change_vec:0x%0h", ocv_i, scv_i, change_vec_i), UVM_MEDIUM)
    
    // CONC-5362 Modifying the change_vec_i incase of all bits set with way for SF being 0
    if(&change_vec_i) begin
        for(int cidx = 0; cidx < ncoreConfigInfo::NUM_CACHES; cidx++) begin
            startBit = 0;
            sf_id = ncoreConfigInfo::get_sfid_assoc2cacheid(cidx);
            for(int i=0;i<sf_id;i++) startBit+= get_tag_sf_handle(i).num_ways;
            tag_sf = get_tag_sf_handle(sf_id);
            mask = ((1 << tag_sf.num_ways) - 1) << startBit;
            isolatedXbits = (way_vec_i & mask) >> startBit;
            //`uvm_info("DIR MGR", $psprintf("fn:commit_request sf_id %0h mask:%0h way_vec_i:%0h iso:%0h", sf_id,mask,way_vec_i,isolatedXbits), UVM_MEDIUM)
            if(~|isolatedXbits) change_vec_i[cidx] = 0;
        end
    end

    //First set write_en for all snoop_filters based on change_vec settings
    for(int cidx = 0; cidx < ncoreConfigInfo::NUM_CACHES; cidx++) begin
        if (change_vec_i[cidx] == 1) begin
            sf_id = ncoreConfigInfo::get_sfid_assoc2cacheid(cidx);
            sf_write_en[sf_id] = 1;
        end
    end
    
    // Parse all the filters for empty cacheline with no change_vec bit set
    commit_entry.cacheline    = offset_align_cacheline(addr_i);

    //HS: 04_13 below code is invalid, since the assumption is that the line would be empty with contents empty only if a line was allocated to it, and write is pending.
//    for (int sidx = 0; sidx < ncoreConfigInfo::NUM_SF; sidx++) begin
//      tag_sf  = get_tag_sf_handle(sidx);
//        set_index = set_index_for_cacheline(commit_entry.cacheline, sidx);
//        for (int widx = 0; widx < tag_sf.num_ways; widx++) begin
//            if(tag_sf.sf_cache[set_index][widx].entry_status == ENTRY_VALID) begin // process only VALID entry
//                oidxq = tag_sf.sf_cache[set_index][widx].ownership.find_index(item) with (item == True);
//                vidxq = tag_sf.sf_cache[set_index][widx].validity.find_index(item) with (item == True);
//                if((oidxq.size()==0) && (vidxq.size()==0)) begin // If EntryValid but EmptyCache line then make it INVALID
//                    tag_sf.sf_cache[set_index][widx].entry_status = ENTRY_INVALID;
//                end
//            end
//        end    
//    end    

    //Below code to set the sf_write_way for all the filters with sf_wr_en set
    startBit = 0;
    for (int sidx = 0; sidx < ncoreConfigInfo::NUM_SF; sidx++) begin
        tag_sf = get_tag_sf_handle(sidx);
        if (sf_write_en[sidx] == 1) begin
            mask = ((1 << tag_sf.num_ways) - 1) << startBit;
            isolatedXbits = (way_vec_i & mask) >> startBit;
            if (isolatedXbits == 0)
                `uvm_error("DIRM MGR", $psprintf("None of the ways are asserted for sf:%0d way_vec:0x%0h change_vec:0x%0h", sidx, way_vec_i, change_vec_i))
            sf_write_way[sidx] = 0;
    //      if(m_dirm_dbg)
    //          `uvm_info("DIRM MGR", $psprintf("fn:commit_request sidx:%0d startBit:%0d num_ways:%0d mask:0x%0h isolatedXbits(way_vec):%0d", sidx, startBit, tag_sf.num_ways, mask, isolatedXbits), UVM_MEDIUM)
            while (isolatedXbits != 0) begin
                if ((isolatedXbits & 'h1) == 1) begin
                    break;          
                end else begin
                    isolatedXbits = isolatedXbits >> 1;
                    sf_write_way[sidx]++;
                end
            end
        end
        startBit = startBit + tag_sf.num_ways;
    end

    //For debug
    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        if(m_dirm_dbg)
            `uvm_info("DIRM MGR", $psprintf("fn:commit_request sfid:%0d sf_wren:%0d sf_wrway:0x%0h, filterType: %s, sfEn: %1b", i, sf_write_en[i], sf_write_way[i], ncoreConfigInfo::snoop_filters_info[i].filter_type, is_snoop_filter_en(i)), UVM_MEDIUM)
    end

    //update snoop_filters
    for(int sidx = 0; sidx < ncoreConfigInfo::NUM_SF; sidx++) begin
        //#Check.DCE.SystemDirectoryCommitsSuppressedIfSnoopFilterEnIsClear
        if((ncoreConfigInfo::snoop_filters_info[sidx].filter_type == "TAGFILTER") && (is_snoop_filter_en(sidx))) begin

            if(sf_write_en[sidx]) begin
                cache_idsq = ncoreConfigInfo::get_sf_assoc_cache_agents(sidx);
                foreach(cache_idsq[i]) begin
                    $sformat(s, "%s cache_idsq[%0d] = %0d\t", s, i, cache_idsq[i]);
                end

                commit_entry.cacheline    = offset_align_cacheline(addr_i);
                set_index = set_index_for_cacheline(commit_entry.cacheline, sidx);
                
                tag_sf  = get_tag_sf_handle(sidx);

                if (sf_entry_validity(ocv_i, scv_i, sidx, cache_idsq) == 0) begin
                    commit_entry.entry_status = ENTRY_INVALID;
                end else begin
                    commit_entry.entry_status = ENTRY_VALID;
                end
                if (m_dirm_dbg)
                    `uvm_info("DIRM MGR", $psprintf("%s >> (status: %s)", s, commit_entry.entry_status.name()), UVM_HIGH)
                    

                //first initialize all ownership/validity values to false, otherwise we see wierd errors
                for(int i = 0; i < ncoreConfigInfo::get_sf_assoc_num_cache_agents(sidx); i++) begin
                    commit_entry.ownership[i] = False;
                    commit_entry.validity[i]  = False;
                end

                foreach(cache_idsq[cidx]) begin
                    ridx = ncoreConfigInfo::rel_indx_within_sf(sidx, cache_idsq[cidx]);
                    assign_ownership_validity_status(sidx, cache_idsq[cidx], ocv_i, scv_i, commit_entry.ownership[ridx], commit_entry.validity[ridx]);
                   `uvm_info("DIRM MGR", $psprintf("fn:commit_request setidx:0x%08h cache_id:%0d ridx:%0d (owner: %p) (validity: %p)", set_index, cache_idsq[cidx], ridx, commit_entry.ownership, commit_entry.validity), UVM_HIGH)
                end

                prev_busy_ways  = tag_sf.get_busy_way_vector(set_index);
                prev_alloc_ways = tag_sf.get_alloc_way_vector(set_index);
                tag_sf.sf_commit(1, set_index, sf_write_way[sidx], commit_entry);
               `uvm_info(get_name(), $psprintf("[%-35s] [sf: %2d] [way: %2d] [addr: 0x%016h] [setIdx: 0x%08h] [allocWays: 0x%06h -> 0x%06h] [busyWays: 0x%06h -> 0x%06h]", "DirModel-CommitUpdate", sidx, sf_write_way[sidx], addr_i, set_index, prev_alloc_ways, tag_sf.get_alloc_way_vector(set_index), prev_busy_ways, tag_sf.get_busy_way_vector(set_index)), UVM_HIGH);
            end       
        end
    end

endfunction: commit_request


//function void directory_mgr::update_model_on_vhit(
//      int                 sfid_i,
//      bit [WSMIADDR:0]    addr_w_sec_i,
//      bit [WSFWAYVEC-1:0] way_vec_i,
//      bit                 eviction_needed_i);
//    
//    bit [WSMIADDR:0]    offset_aligned_addr_w_sec;
//    bit [WSFWAYVEC-1:0] mask;
//    bit [WSFSETIDX-1:0]   set_index;
//    tag_snoop_filter    tag_sf, req_tag_sf;    
//    int                   startBit = 0;
//    int                   alloc_way = 0;
//    int                   isolatedXbits;
//    tag_snoop_filter_t  ign1;
//    int ign2, ign4;
//    bit ign3;
//  
//  offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
//    req_tag_sf                  = get_tag_sf_handle(sfid_i);
//    set_index                   = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid_i);
//
//  //code to extract way_num 
//    for (int sidx = 0; sidx < ncoreConfigInfo::NUM_SF; sidx++) begin
//      tag_sf = get_tag_sf_handle(sidx);
//      if (sidx == sfid_i) begin
//          mask = ((1 << tag_sf.num_ways) - 1) << startBit;
//          isolatedXbits = (way_vec_i & mask) >> startBit;
//          if (isolatedXbits == 0)
//              `uvm_error("DIRM MGR", $psprintf("None of the ways are asserted to swap request on vhit: sf:%0d way_vec:0x%0h", sfid_i, way_vec_i))
//          alloc_way = 0;
//          `uvm_info("DIRM MGR", $psprintf("fn:update_model_on vhit sfid:%0d startBit:%0d num_ways:%0d mask:0x%0h isolatedXbits:%0d", sfid_i, startBit, tag_sf.num_ways, mask, isolatedXbits), UVM_MEDIUM)
//          while (isolatedXbits != 0) begin
//              if ((isolatedXbits & 'h1) == 1) begin
//                  break;          
//              end else begin
//                  isolatedXbits = isolatedXbits >> 1;
//                  alloc_way++;
//              end
//          end
//          break;
//      end
//      startBit = startBit + tag_sf.num_ways;
//    end
//  
//  if (alloc_way >= req_tag_sf.num_ways)
//        `uvm_error("DIRM MGR", $psprintf("alloc_way(%0d) is greater or equal to num_ways(%0d) for sfid(%0d))", alloc_way, tag_sf.num_ways, sfid_i))
//
//    
//  
//
//endfunction: update_model_for_vhit

//dirm scb calls this on receiving dir_rsp. does lookup and forwards 
//olv, slv, sf_writes & ways allocated.
function void directory_mgr::repair_model_on_hitway_mismatch(
    int                 sfid_i,
    bit [WSMIADDR:0]    addr_w_sec_i,
    bit [WSFWAYVEC-1:0] way_vec_i);

    tag_snoop_filter_t  hit_entry;
    bit [WSMIADDR:0]    offset_aligned_addr_w_sec;
    bit [WSFSETIDX-1:0] set_index;
    tag_snoop_filter    tag_sf;
    int                 rtl_way, dv_way;
    bit                 ign;
   
//      tag_sf = get_tag_sf_handle(0);
//      set_index = 'h12;
//  if (tag_sf.sf_cache.exists(set_index)) begin
//      foreach (tag_sf.sf_cache[set_index][way_idx]) begin  //loop through all ways in set, and check if busy ways are matched with RTL busy_vec.
//          `uvm_info("REPAIR_MODEL_HITWAY_MISMATCH TAG SF0 DATA", $psprintf("set_index:0x12 %0s", tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][way_idx], way_idx)), UVM_MEDIUM)
//      end
//  end

    tag_sf                    = get_tag_sf_handle(sfid_i);
    offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    set_index                 = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid_i);
    rtl_way                   = get_waynum(sfid_i, way_vec_i);
    
    `uvm_info("TAG SF", $psprintf("fn: repair_model_on_hitway_mismatch swap contents between ways TF for sfid:%0d set_index:0x%0h rtl_way:%0d", sfid_i, set_index, rtl_way), UVM_MEDIUM)

    if (tag_sf.entry_exists_in_tag_filter(set_index, offset_aligned_addr_w_sec, dv_way) == 0) begin
            `uvm_error("TAG SF", $psprintf("fn: repair_model_on_hitway_mismatch model should say TF hit"))
    end else begin //TAG hit
            if (rtl_way == dv_way)
                `uvm_error("TAG SF", $psprintf("fn: repair_model_on_hitway_mismatch rtl_way == dv_way. Whats there to fix?"))
            hit_entry.entry_status   = tag_sf.sf_cache[set_index][dv_way].entry_status;
            hit_entry.cacheline      = tag_sf.sf_cache[set_index][dv_way].cacheline;
            hit_entry.busy           = tag_sf.sf_cache[set_index][dv_way].busy;

            for(int i = 0; i < tag_sf.get_num_cacheing_agents(); i++) begin
                hit_entry.ownership[i]      = tag_sf.sf_cache[set_index][dv_way].ownership[i];
                hit_entry.validity[i]       = tag_sf.sf_cache[set_index][dv_way].validity[i];
            end
            tag_sf.assign_tag_filter_entry(set_index, dv_way,  tag_sf.sf_cache[set_index][rtl_way]);
            tag_sf.assign_tag_filter_entry(set_index, rtl_way, hit_entry);
    end
    
//      tag_sf = get_tag_sf_handle(0);
//      set_index = 'h12;
//  if (tag_sf.sf_cache.exists(set_index)) begin
//      foreach (tag_sf.sf_cache[set_index][way_idx]) begin  //loop through all ways in set, and check if busy ways are matched with RTL busy_vec.
//          `uvm_info("REPAIR_MODEL_HITWAY_MISMATCH TAG SF0 DATA", $psprintf("set_index:0x12 %0s", tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][way_idx], way_idx)), UVM_MEDIUM)
//      end
//  end

endfunction: repair_model_on_hitway_mismatch

function void directory_mgr::repair_model_on_vbhit_mismatch(
        int                 sfid_i,
        bit [WSMIADDR:0]    addr_w_sec_i,
        bit [WSFWAYVEC-1:0] way_vec_i);

    tag_snoop_filter_t  old_tf_entry;
    tag_snoop_filter_t  vctb_entry;
    bit [WSMIADDR:0]    offset_aligned_addr_w_sec;
    bit [WSFSETIDX-1:0] set_index;
    tag_snoop_filter    tag_sf;
    int                 swap_way;
    int                 vhit_idx_o;
    bit                 ign, vb_hit, recall_flop_hit;
   
//      tag_sf = get_tag_sf_handle(0);
//      set_index = 'h12;
//  if (tag_sf.sf_cache.exists(set_index)) begin
//      foreach (tag_sf.sf_cache[set_index][way_idx]) begin  //loop through all ways in set, and check if busy ways are matched with RTL busy_vec.
//          `uvm_info("REPAIR_MODEL TAG SF0 DATA", $psprintf("set_index:0x12 %0s", tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][way_idx], way_idx)), UVM_MEDIUM)
//      end
//  end

    tag_sf                    = get_tag_sf_handle(sfid_i);
    offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    set_index                 = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid_i);
    swap_way                  = get_waynum(sfid_i, way_vec_i);
   
    if(m_dirm_dbg)
        `uvm_info("TAG SF", $psprintf("fn: repair_model_on_vbhit_mismatch model:VB hit rtl:VB miss so move back VB entry into TF for sfid:%0d set_index:0x%0h swap_way:%0d", sfid_i, set_index, swap_way), UVM_MEDIUM)
    
    vb_hit = tag_sf.entry_exists_in_victim_buffer(offset_aligned_addr_w_sec, vhit_idx_o, ign) ? 1 : 0;
    recall_flop_hit = ((tag_sf.recall_entry.entry_status == ENTRY_VALID) && (tag_sf.recall_entry.cacheline == offset_aligned_addr_w_sec)) ? 1 : 0;
    
    if(m_dirm_dbg)
        `uvm_info("TAG SF", $psprintf("fn: repair_model_on_vbhit_mismatch VB hit:%0d recall_flop hit:%0d", vb_hit, recall_flop_hit), UVM_MEDIUM)
    
    if ((vb_hit == 0) && (recall_flop_hit == 0)) begin
            `uvm_error("TAG SF", $psprintf("fn: repair_model_on_vbhit_mismatch model should say VB hit or recall_flop_hit"))
    end else begin 
        if(tag_sf.sf_cache.exists(set_index)) begin
            if (tag_sf.sf_cache[set_index][swap_way].entry_status == ENTRY_VALID) begin
                old_tf_entry.entry_status   = tag_sf.sf_cache[set_index][swap_way].entry_status;
                old_tf_entry.cacheline      = tag_sf.sf_cache[set_index][swap_way].cacheline;
                old_tf_entry.busy           = tag_sf.sf_cache[set_index][swap_way].busy;

                for(int i = 0; i < tag_sf.get_num_cacheing_agents(); i++) begin
                    old_tf_entry.ownership[i]      = tag_sf.sf_cache[set_index][swap_way].ownership[i];
                    old_tf_entry.validity[i]       = tag_sf.sf_cache[set_index][swap_way].validity[i];
                end
            end
        end else begin 
            `uvm_error("TAG SF", $psprintf("fn: repair_model_on_vbhit_mismatch sfid:%0d set_index:0x%0h does not exists", sfid_i, set_index))
        end
        if (vb_hit == 1) begin //VB hit
            //tag_sf.move_vb_entry_to_sf(vhit_idx_o, set_index, swap_way); // Requires (1)Index of VB entry to move, (2) Set_index of current SF, (3) way of current SF
            tag_sf.assign_tag_filter_entry(set_index, swap_way, tag_sf.m_victim_buffer[vhit_idx_o]);
            tag_sf.m_victim_buffer.delete(vhit_idx_o);
            if (old_tf_entry.entry_status == ENTRY_VALID) begin 
                tag_sf.m_victim_buffer.push_front(old_tf_entry);
                if(m_dirm_dbg)
                    `uvm_info("VB SF", $psprintf("repair model_on_vbhit mismatch: After VB push VB%0d %s", sfid_i, tag_sf.conv_vctb_info2string()), UVM_MEDIUM);
            end
        end //VB hit
        else if (recall_flop_hit == 1) begin 
            tag_sf.assign_tag_filter_entry(set_index, swap_way, tag_sf.recall_entry);
            tag_sf.recall_entry.entry_status = ENTRY_INVALID;
            tag_sf.recall_entry.cacheline = 0;
            if (tag_sf.m_victim_buffer.size() != tag_sf.get_vctb_depth()) begin//vb not full
                tag_sf.m_victim_buffer.push_front(old_tf_entry);
                if(m_dirm_dbg)
                    `uvm_info("VB SF", $psprintf("repair model_on_vbhit mismatch: After VB push VB%0d %s", sfid_i, tag_sf.conv_vctb_info2string()), UVM_MEDIUM);
            end else begin //vb full -- so move tf entry to recall flop
                tag_sf.recall_entry.entry_status = ENTRY_VALID;
                tag_sf.recall_entry.cacheline    = old_tf_entry.cacheline;
                tag_sf.recall_entry.busy         = old_tf_entry.busy;
                for (int cacheid = 0; cacheid < tag_sf.get_num_cacheing_agents(); cacheid++) begin
                    tag_sf.recall_entry.ownership[cacheid] = old_tf_entry.ownership[cacheid];
                    tag_sf.recall_entry.validity[cacheid]  = old_tf_entry.validity[cacheid];
                end
            end
        end //recall flop hit
    end // at least one of vb_hit or recall_hit is true
endfunction: repair_model_on_vbhit_mismatch

function void directory_mgr::check_dm_lkprsp_swap_way_on_vbhit(bit [WSFWAYVEC-1:0] way_vec_i, bit [ncoreConfigInfo::NUM_SF-1:0] vbhit_sfvec_i);
    
    //#Check.DCE.DM.CmdRsp_VBSwapWay    
    for (int sidx = 0; sidx < ncoreConfigInfo::NUM_SF; sidx++) begin
        if (vbhit_sfvec_i[sidx] == 1 && (get_waynum(sidx, way_vec_i) == -1))
            `uvm_error("DIRM MGR", $psprintf("None of the ways are asserted for request that hit in VB sf:%0d way_vec:0x%0h", sidx, way_vec_i))
    end

endfunction: check_dm_lkprsp_swap_way_on_vbhit

function void directory_mgr::update_model_for_allocating_request_or_vhit(
    int                 sfid_i,
    bit [WSMIADDR:0]    addr_w_sec_i,
    bit [WSFWAYVEC-1:0] way_vec_i,
    bit                 eviction_needed_i);

    bit [WSMIADDR:0]    offset_aligned_addr_w_sec;
    bit [WSFWAYVEC-1:0] mask;
    bit [WSFSETIDX-1:0] set_index;
    tag_snoop_filter    tag_sf, req_tag_sf;  
    int                 startBit = 0;
    int                 alloc_way, hit_way;
    int                 isolatedXbits;
    tag_snoop_filter_t  ign1;
    int ign2, ign3;
    bit vhit;

    offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    req_tag_sf                = get_tag_sf_handle(sfid_i);
    set_index                 = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid_i);

    alloc_way = get_waynum(sfid_i, way_vec_i);
   `uvm_info(get_name(), $psprintf("[%-35s] [sf: %2d] [way: %2d] [addr: 0x%016h] [setIdx: 0x%08h]", "DirModel-LkupUpdateInit", sfid_i, alloc_way, addr_w_sec_i, set_index), UVM_HIGH);
    
    //#Check.DCE.dm_CmdRspWayVecAllocReq
    if (alloc_way == -1)
        `uvm_error("DIRM MGR", $psprintf("No ways is asserted for allocating request or vhit sf:%0d way_vec:0x%0h", sfid_i, way_vec_i))
    
    if (req_tag_sf.snoop_filter_hit(set_index, offset_aligned_addr_w_sec, ign1, hit_way, vhit, ign3))   begin
       `uvm_info(get_name(), $psprintf("[%-35s] [sf: %2d] [way: %2d] [addr: 0x%016h] [evictOn: %1d] [setIdx: 0x%08h] [hitWay: %2d] [vbHit: %1b]", "DirModel-LkupHitUpdate", sfid_i, alloc_way, addr_w_sec_i, eviction_needed_i, set_index, hit_way, vhit), UVM_HIGH);
        if (vhit == 0) begin
            req_tag_sf.sf_cache[set_index][hit_way].busy    = 1;
            req_tag_sf.sf_cache[set_index][hit_way].wr_pend = 1;
            if (hit_way != alloc_way) 
                `uvm_error("DIRM MGR", $psprintf("fn:update_model_for_alloc_request mismatch model_hit_way:%0d rtl_hit_way:%0d", hit_way, alloc_way))
            return;
        end else begin
            delete_entry_in_vb(offset_aligned_addr_w_sec, sfid_i); 
        end
    end
    
    if (alloc_way >= req_tag_sf.num_ways)
        `uvm_error("DIRM MGR", $psprintf("alloc_way(%0d) is greater or equal to num_ways(%0d) for sfid(%0d))", alloc_way, tag_sf.num_ways, sfid_i))
    
    req_tag_sf.allocate_sf_segment(set_index, offset_aligned_addr_w_sec, alloc_way, eviction_needed_i);
   `uvm_info(get_name(), $psprintf("[%-35s] [sf: %2d] [way: %2d] [addr: 0x%016h] [setIdx: 0x%08h] [allocWayVec: 0x%06h] [dmBusyVec: 0x%06h]", "DirModel-LkupUpdateDone", sfid_i, alloc_way, addr_w_sec_i, set_index, req_tag_sf.get_alloc_way_vector(set_index), req_tag_sf.get_busy_way_vector(set_index)), UVM_HIGH);
endfunction: update_model_for_allocating_request_or_vhit

function void directory_mgr::update_model_for_deallocating_request(
        int                 sfid_i,
        bit [WSMIADDR:0]    addr_w_sec_i,
        bit [WSFWAYVEC-1:0] way_vec_i,
        bit                 eviction_needed_i);

    bit [WSMIADDR:0]    offset_aligned_addr_w_sec;
    bit [WSFWAYVEC-1:0] mask;
    bit [WSFSETIDX-1:0] set_index;
    tag_snoop_filter    tag_sf, req_tag_sf;  
    int                 startBit = 0;
    int                 alloc_way = 0;
    int                 isolatedXbits;
    tag_snoop_filter_t  ign1;
    int ign2, ign3;
    bit vhit;

    offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i); // Get the cacheline address
    req_tag_sf                = get_tag_sf_handle(sfid_i); // Get the required Tag Filter Handle
    set_index                 = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid_i); // Get the cacheline entry index in Tag filter

    // We are deallocating the cacheline incase of snarf=0 for StashOnce txns
    if (req_tag_sf.snoop_filter_hit(set_index, offset_aligned_addr_w_sec, ign1, ign2, vhit, ign3))  begin
        `uvm_info("DIRM MGR", $psprintf("fn:update_model_for_dealloc_request vhit:%0d", vhit), UVM_MEDIUM)
        if (vhit == 0) begin
            // ------------------------
            // De-allocated this entry after finding its way
            // ------------------------
            // Get the way_number for allocation from way_vector
            for (int sidx = 0; sidx < ncoreConfigInfo::NUM_SF; sidx++) begin
                tag_sf = get_tag_sf_handle(sidx);
                if (sidx == sfid_i) begin
                    mask = ((1 << tag_sf.num_ways) - 1) << startBit;
                    isolatedXbits = (way_vec_i & mask) >> startBit;
                    if (isolatedXbits == 0)
                        `uvm_error("DIRM MGR", $psprintf("None of the ways are asserted for de-allocating request sf:%0d way_vec:0x%0h", sfid_i, way_vec_i))
                    alloc_way = 0;
                    `uvm_info("DIRM MGR", $psprintf("fn:update_model_for_dealloc_request sfid:%0d startBit:%0d num_ways:%0d mask:0x%0h isolatedXbits:%0d", sfid_i, startBit, tag_sf.num_ways, mask, isolatedXbits), UVM_MEDIUM)
                    while (isolatedXbits != 0) begin
                        if ((isolatedXbits & 'h1) == 1) begin
                            break;          
                        end else begin
                            isolatedXbits = isolatedXbits >> 1;
                            alloc_way++;
                        end
                    end
                    break;
                end
                startBit = startBit + tag_sf.num_ways;
            end
            
            if (alloc_way >= req_tag_sf.num_ways)
                `uvm_error("DIRM MGR", $psprintf("de-alloc_way(%0d) is greater or equal to num_ways(%0d) for sfid(%0d))", alloc_way, tag_sf.num_ways, sfid_i))
            
            if (m_dirm_dbg) 
                `uvm_info("DIRM MGR", $psprintf("fn:update_model_for_dealloc_request-- Need to de-allocate sf_segment in sfid:%0d set_idx:0x%0h way:%0d eviction_needed:%0d", sfid_i, set_index, alloc_way, eviction_needed_i), UVM_MEDIUM)
        end else begin
            // SM: In case for VB_HIT need to ask Khaleel for DM and TM behaviour
            // As the hit entry will be deleted from the VB_list as it will be commited to complete the SWAP.
            // And the picked way entry will be written in the VB_list inplace of removed entry.
            // The entry deleted in the VB will be same as the LKP_RSP, we can copy back to restore it
            //delete_entry_in_vb(offset_aligned_addr_w_sec, sfid_i); 
        end
    end 


    req_tag_sf.deallocate_sf_segment(set_index, offset_aligned_addr_w_sec, alloc_way, eviction_needed_i);


    //populate_vb_list();
    //populate_recall_list();
endfunction: update_model_for_deallocating_request


function void directory_mgr::update_model(
    int                 sfid_i,
    bit                 hf_allocreq_i,
    bit [WSMIADDR:0]    addr_w_sec_i,
    bit [WSFWAYVEC-1:0] way_vec_i,
    bit                 wr_required_i);

    int alloc_hit_way                          = get_waynum(sfid_i, way_vec_i);
    bit [WSMIADDR:0] offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    bit [WSFSETIDX-1:0] set_index              = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid_i);

    tag_snoop_filter req_tag_sf  = get_tag_sf_handle(sfid_i);
    if (alloc_hit_way == -1) begin 
        return ;
    end else begin //either alloc miss, or vbhit, or taghit
       if (req_tag_sf.sf_cache.exists(set_index) == 0)
            `uvm_error("DCE DIRM", $psprintf("fn:update_model_for_hit sfid:%0d setidx:0x%0h does not exist in model", sfid_i, set_index)) 
        
       /*if (req_tag_sf.sf_cache[set_index].size() <= alloc_hit_way) Not valid with pLRU because way number doesn't increment sequentially example 8-way way 0 and way 4 will be picked
            `uvm_error("DCE DIRM", $psprintf("fn:update_model_for_hit sfid:%0d setidx:0x%0h way:%0d does not exist in model", sfid_i, set_index, alloc_hit_way))*/

       if (   (req_tag_sf.sf_cache[set_index][alloc_hit_way].entry_status != ENTRY_VALID)
           || (req_tag_sf.sf_cache[set_index][alloc_hit_way].cacheline != offset_aligned_addr_w_sec)) begin
            `uvm_error("DCE DIRM", $psprintf("fn:update_model_for_hit sfid:%0d setidx:0x%0h way:%0d entry_status:%0p cacheline:0x%0h wr_pend:%0b", 
                    sfid_i, 
                    set_index, 
                    alloc_hit_way,
                    req_tag_sf.sf_cache[set_index][alloc_hit_way].entry_status,
                    req_tag_sf.sf_cache[set_index][alloc_hit_way].cacheline,
                    req_tag_sf.sf_cache[set_index][alloc_hit_way].wr_pend
                ))
       end

       if (hf_allocreq_i || wr_required_i) begin
            req_tag_sf.sf_cache[set_index][alloc_hit_way].wr_pend = 1;
       end
       `uvm_info("DCE DM MODEL", $psprintf("sfid:%0d setidx:0x%0h way:%0d wr_pend:%0b", sfid_i, set_index, alloc_hit_way, req_tag_sf.sf_cache[set_index][alloc_hit_way].wr_pend), UVM_MEDIUM)
    end 

endfunction: update_model

function void directory_mgr::lookup_request(
    bit [WSMIADDR:0]                          addr_w_sec_i,
    int                                       iid_i,
    bit                                       alloc_i,
    bit [$clog2(ncoreConfigInfo::NUM_SF)-1:0]    filter_num_i,
    bit [WSFWAYVEC-1:0]                       busy_vec_tm_i,
    bit [WSFWAYVEC-1:0]                       busy_vec_dm_i,
    bit [WSFWAYVEC-1:0]                       pipelined_req_vec_i,
    output bit [ncoreConfigInfo::NUM_CACHES-1:0] olv_o,
    output bit [ncoreConfigInfo::NUM_CACHES-1:0] slv_o,
    output bit [WSFWAYVEC-1:0]                way_vec_o,
    output bit [ncoreConfigInfo::NUM_SF-1:0]     eviction_needed_sfvec_o,
    inout int                                 evict_wayq_o[$],
    output bit [ncoreConfigInfo::NUM_SF-1:0]     vbhit_sfvec_o,
    output bit [ncoreConfigInfo::NUM_SF-1:0]     tfhit_sfvec_o,
    inout int                                 hit_wayq_o[$]);

    bit [WSMIADDR:0]     offset_aligned_addr_w_sec;
    int                  cache_id;
    bit [WSFSETIDX-1:0]  set_index;
    tag_snoop_filter     tag_sf;
    int                  alloc_way;
    int                  evict_way;
    int                  hit_evict_way;
    sf_info_t            sf_info[$];
    int                  busy_waysq[$];
    tag_snoop_filter_t   hit_entry;
    int ign3;
    bit set_full;
    
    //reset all outputs
    olv_o                   = 0;
    slv_o                   = 0;
    way_vec_o               = 0;
    vbhit_sfvec_o           = 0;
    tfhit_sfvec_o           = 0;
    eviction_needed_sfvec_o = 0;
    evict_wayq_o.delete();
    hit_wayq_o.delete();
    busy_waysq.delete();

    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        sf_info[i].vld = 0;
        evict_wayq_o.push_back(0);
        hit_wayq_o.push_back(0);
    end

    offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    cache_id                  = ncoreConfigInfo::get_cache_id(iid_i);
                
    if (m_dirm_dbg)
        `uvm_info("DIRM MGR", $psprintf("fn:lookup_request: busy_vec_tm:0x%0h busy_vec_dm:0x%0h pipelined_req_vec:0x%0h cache_id:%0d", busy_vec_tm_i, busy_vec_dm_i, pipelined_req_vec_i, cache_id), UVM_MEDIUM)

    for(int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        
        bit eviction_needed = 0;
        bit vb_hit = 0;
        busy_waysq.delete();
        tag_sf = get_tag_sf_handle(sfid);

        set_index = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid);
        sf_info[sfid].set_index = set_index;
            
        if (pipelined_req_vec_i[sfid] == 1)
            get_busy_ways(busy_vec_dm_i, sfid, busy_waysq);
        else
            get_busy_ways(busy_vec_tm_i, sfid, busy_waysq);
        
        check_busy_waysq(busy_waysq, sfid, set_index);
                
        if (busy_waysq.size() == tag_sf.num_ways)
            tag_sf.obsrvd_all_ways_busy = 1;

        if (alloc_i && (sfid == filter_num_i))
            tag_sf.obsrvd_home_filter = 1;

        //SF HIT
        if (tag_sf.snoop_filter_hit(set_index, offset_aligned_addr_w_sec, hit_entry, hit_evict_way, vb_hit, ign3)) begin
            `uvm_info("DIRM MGR", $psprintf("SF Hit sfid:%0d offset_aligned_addr_w_sec:0x%0h set_index:0x%0h vb_hit:%0d", sfid, offset_aligned_addr_w_sec, set_index, vb_hit), UVM_MEDIUM)

            if (vb_hit)
                tag_sf.obsrvd_vctb_hit = 1;

            if ((busy_waysq.size() == tag_sf.num_ways) && vb_hit) begin
                `uvm_info("DIRM MGR", $psprintf("fn: lookup_request-- return early, this request will retry for sure since all ways are busy in sfid:%0d and it is a VB hit", sfid), UVM_MEDIUM)
                return;
            end
                
            if (vb_hit == 1) begin //VB hit
                vbhit_sfvec_o[sfid] = 1;
                tag_sf.get_possible_alloc_way_at_lookup(set_index, busy_waysq, alloc_way, eviction_needed);
                
                if(m_dirm_dbg)
                    `uvm_info("DIRM MGR", $psprintf("SF Miss: Alloc txn sfid:%0d set_idx:0x%0h alloc_way:%0d eviction_needed:%0d", sfid, set_index, alloc_way, eviction_needed), UVM_MEDIUM)
                sf_info[sfid].way = alloc_way;
                    
            end else begin //TAGFILTER hit
                tfhit_sfvec_o[sfid] = 1;
                hit_wayq_o[sfid]    = hit_evict_way;
                sf_info[sfid].way = hit_evict_way;

                // mark the hit way as busy, since there could be a write to that way later.
                // YRAMASAMY
                // Commenting the following out as this causes unnecessary issues during prediction! Anyways, this gets updated in the lookup response
                // and hence commenting this out
                //tag_sf.sf_cache[set_index][hit_evict_way].busy = 1; 
               `uvm_info("DIRM MGR", $psprintf("Marked busy on tag-filter hit %0s", tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][hit_evict_way], hit_evict_way)), UVM_MEDIUM)
            end

            sf_info[sfid].vld = 1;
            for (int cacheid = 0; cacheid < tag_sf.get_num_cacheing_agents(); cacheid++) begin
                sf_info[sfid].ownership[cacheid] = hit_entry.ownership[cacheid];
                sf_info[sfid].validity[cacheid]  = hit_entry.validity[cacheid];
            end

        end //SF HIT
        //SF MISS
        else begin
            if(cache_id != -1) begin
                if ((ncoreConfigInfo::cacheid_assoc_with_sfid(sfid, cache_id)) && (alloc_i == 1)) begin 
                    tag_sf.is_set_full(set_index, 1, set_full);
                    tag_sf.obsrvd_alloc_miss = 1; //need this to sample on rtyrsp coverage
                    if (busy_waysq.size() == tag_sf.num_ways) begin //all_ways busy
                        `uvm_info("DIRM MGR", $psprintf("fn: lookup_request-- return early, this request will retry for sure since all ways are busy for the allocating_request in home_filter sfid:%0d", sfid), UVM_MEDIUM)
                        return;
                    end
                        
                    tag_sf.get_possible_alloc_way_at_lookup(set_index, busy_waysq, alloc_way, eviction_needed);

                    sf_info[sfid].vld = 1;
                    sf_info[sfid].way = alloc_way;
                    for (int cacheid = 0; cacheid < tag_sf.get_num_cacheing_agents(); cacheid++) begin
                        sf_info[sfid].ownership[cacheid] = False;
                        sf_info[sfid].validity[cacheid]  = False;
                    end
                    if(m_dirm_dbg)
                        `uvm_info("DIRM MGR", $psprintf("SF Miss: Alloc txn sfid:%0d set_idx:0x%0h alloc_way:%0d eviction_needed:%0d", sfid, set_index, alloc_way, eviction_needed), UVM_MEDIUM)
                end else begin
                    if (m_dirm_dbg)
                        `uvm_info("DIRM MGR", $psprintf("SF Miss: Non Alloc txn sfid:%0d set_idx:0x%0h", sfid, set_index), UVM_MEDIUM)
                    sf_info[sfid].vld = 0;
                end 
            end else begin //cache_id == -1  
                if (m_dirm_dbg)
                    `uvm_info("DIRM MGR", $psprintf("SF Miss: lookup is from a non cacheing agent sfid:%0d iid:%0d", sfid, iid_i), UVM_MEDIUM)
            end 
        end //SF MISS
            //set the SF that needs eviction
            if (eviction_needed) begin
                eviction_needed_sfvec_o[sfid] = 1;
                evict_wayq_o[sfid] = alloc_way;
            end
    end //loop through all SFs
    
    if (m_dirm_dbg) 
         `uvm_info("DIRM MGR", $psprintf("eviction_needed_sfvec:0x%0h vbhit_sfvec:0x%0h tfhit_sfvec:0x%0h", eviction_needed_sfvec_o, vbhit_sfvec_o, tfhit_sfvec_o), UVM_MEDIUM)

    construct_lookup_vectors(sf_info, olv_o, slv_o, way_vec_o);

endfunction: lookup_request 

function void directory_mgr::check_busy_waysq( int q[$], int sfid, bit [WSFSETIDX-1 : 0] set_index);

    tag_snoop_filter tag_sf = get_tag_sf_handle(sfid);
            
    if (tag_sf.sf_cache.exists(set_index)) begin
        foreach(q[i]) begin //loop through all the busy ways
            if (q[i] > tag_sf.sf_cache[set_index].size()) begin
                `uvm_error("TAG SF", $psprintf("SF-%0d set_index:%0h way:%0d marked busy when it was never accessed before current set_index_size:%0d", sfid, set_index, q[i], tag_sf.sf_cache[set_index].size()))
            end else begin
                //TODO: 04_09 cant enable this check since busy indication by TM is not gone at dm_write_req but stays ON until attid is deallocated.
//              if ((tag_sf.sf_cache[set_index][q[i]].entry_status != ENTRY_VALID) || !tag_sf.sf_cache[set_index][q[i]].busy)
//                  `uvm_error("TAG SF", $psprintf("SF-%0d set_index:%0h way:%0d marked busy incorrectly\n%0s", sfid, set_index, q[i], tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][q[i]], q[i])))
            end 
        end
        foreach (tag_sf.sf_cache[set_index][way_idx]) begin  //loop through all ways in set, and check if busy ways are matched with RTL busy_vec.
            //TODO: disabled 04_09 re-enable after debug
//          if ( (tag_sf.sf_cache[set_index][way_idx].entry_status == ENTRY_VALID) && 
//               (tag_sf.sf_cache[set_index][way_idx].busy         == 1)           &&
//               !(way_idx inside {q}))
//                  `uvm_error("TAG SF", $psprintf("SF-%0d set_index:0x%0h way:%0d should be marked busy and protected by TM\n%0s", sfid, set_index, way_idx, tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][way_idx], way_idx)))
        end 
    end else begin// set does not exists. busy_waysq should be 0 
        if (q.size() != 0)
            `uvm_error("TAG SF", $psprintf("SF-%0d set_index:%0h has busy ways when it is accessed for 1st time", sfid, set_index))
    end

endfunction: check_busy_waysq

function void directory_mgr::clear_busy_on_attid_dealloc(bit [WSMIADDR:0] addr_w_sec_i);
    bit [WSMIADDR:0]     offset_aligned_addr_w_sec;
    bit [WSFSETIDX-1:0]  set_index;
    tag_snoop_filter   tag_sf;
    tag_snoop_filter_t hit_entry;
    int ign3;
    bit vb_hit = 0;
    int hit_evict_way = -1;

    offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);
    
    for(int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        
        tag_sf = get_tag_sf_handle(sfid);
        set_index = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid);
        if (tag_sf.snoop_filter_hit(set_index, offset_aligned_addr_w_sec, hit_entry, hit_evict_way, vb_hit, ign3)) begin
            `uvm_info("DIRM MGR", $psprintf("fn:clear_busy_attid_dealloc SF Hit sfid:%0d offset_aligned_addr_w_sec:0x%0h set_index:0x%0h vb_hit:%0d", sfid, offset_aligned_addr_w_sec, set_index, vb_hit), UVM_MEDIUM)

            if (vb_hit == 0) begin //VB hit
                tag_sf.sf_cache[set_index][hit_evict_way].busy    = 0;
                tag_sf.sf_cache[set_index][hit_evict_way].wr_pend = 0;
            end
        end
    end
endfunction: clear_busy_on_attid_dealloc


function void directory_mgr::get_busy_ways( bit [WSFWAYVEC-1:0] busy_vec_i, 
                                            int        sfid_i,
                                            inout int    busy_waysq_o[$] );

    tag_snoop_filter tag_sf;
    int              way_num;
    string           s;

    //code for creating busy_waysq
    for (int i = 0; i < sfid_i; i++) begin
        tag_sf = get_tag_sf_handle(i);
        busy_vec_i = busy_vec_i >> tag_sf.num_ways;
    end

    //`uvm_info("DBG", $psprintf("busy_vec before - 0x%0h", busy_vec_i), UVM_MEDIUM);
    tag_sf = get_tag_sf_handle(sfid_i);
    busy_vec_i = busy_vec_i & ((2 ** tag_sf.num_ways) - 1);
    
    //`uvm_info("DBG", $psprintf("busy_vec after- 0x%0h", busy_vec_i), UVM_MEDIUM);
                        
    way_num = 0;
    while (busy_vec_i != 0) begin
        if (busy_vec_i & 1'b1 == 1) begin
            busy_waysq_o.push_back(way_num);
        end
        busy_vec_i = busy_vec_i >> 1;
        way_num++;
    end
                        
    $sformat(s, "SF ID:%0d busy_wayq.size: %0d busy ways are--", sfid_i, busy_waysq_o.size());
    foreach(busy_waysq_o[i]) begin
        $sformat(s, "%0s %0d\t", s, busy_waysq_o[i]);
    end 
       
    if(m_dirm_dbg)
        `uvm_info("TAG SF", s, UVM_MEDIUM)

endfunction: get_busy_ways

//******************delete cacheline in vb***************************************************//
function void directory_mgr::delete_entry_in_tf(bit [WSMIADDR:0] cacheline_addr, int sfid);
    tag_snoop_filter   tag_sf;
    int                index;
    bit                found;
    bit [WSFSETIDX-1:0] set_index;
    int                found_way;
        
    tag_sf    = get_tag_sf_handle(sfid);
    set_index = set_index_for_cacheline(cacheline_addr, sfid);

    if (tag_sf.entry_exists_in_tag_filter(set_index, cacheline_addr, found_way)) begin 
        if(m_dirm_dbg)
            `uvm_info("DIRM MGR", $psprintf("Entry to be deleted in TF%0d since it is recalled: %s", sfid, tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][found_way], found_way)), UVM_MEDIUM)
        if (    (tag_sf.recall_entry.entry_status == ENTRY_VALID)
             && (set_index_for_cacheline(tag_sf.recall_entry.cacheline, sfid) == set_index)) begin
            tag_sf.sf_cache[set_index][found_way].entry_status = ENTRY_VALID;
            tag_sf.sf_cache[set_index][found_way].cacheline    = tag_sf.recall_entry.cacheline;
            tag_sf.sf_cache[set_index][found_way].busy         = 0;

            for (int cacheid = 0; cacheid < tag_sf.get_num_cacheing_agents(); cacheid++) begin
                tag_sf.sf_cache[set_index][found_way].ownership[cacheid] = tag_sf.recall_entry.ownership[cacheid];
                tag_sf.sf_cache[set_index][found_way].validity[cacheid]  = tag_sf.recall_entry.validity[cacheid];
            end
            tag_sf.recall_entry.entry_status = ENTRY_INVALID;
            tag_sf.recall_entry.cacheline    = 0;
            tag_sf.recall_entry.busy         = 0;
            for (int cacheid = 0; cacheid < tag_sf.get_num_cacheing_agents(); cacheid++) begin
                tag_sf.recall_entry.ownership[cacheid] = False;
                tag_sf.recall_entry.validity[cacheid]  = False;
            end
            if(m_dirm_dbg)
                `uvm_info("DIRM MGR", $psprintf("moved entry from recall_flop to TF%0d: %s", sfid, tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][found_way], found_way)), UVM_MEDIUM)
        end else if (tag_sf.check_for_possible_vb_recovery(set_index, found_way) == 1) begin
                `uvm_info("DIRM MGR", $psprintf("moved entry from VB to TF%0d: %s", sfid, tag_sf.conv_sf_info2string(tag_sf.sf_cache[set_index][found_way], found_way)), UVM_MEDIUM)
        end else begin
            tag_sf.sf_cache[set_index][found_way].entry_status = ENTRY_INVALID;
            tag_sf.sf_cache[set_index][found_way].cacheline    = 0;
            tag_sf.sf_cache[set_index][found_way].busy         = 0;

            for (int cacheid = 0; cacheid < tag_sf.get_num_cacheing_agents(); cacheid++) begin
                tag_sf.sf_cache[set_index][found_way].ownership[cacheid] = False;
                tag_sf.sf_cache[set_index][found_way].validity[cacheid]  = False;
            end
        end
    end
endfunction: delete_entry_in_tf

//******************delete cacheline in vb***************************************************//
function void directory_mgr::delete_entry_in_vb(bit [WSMIADDR:0] cacheline_addr, int sfid);
    tag_snoop_filter   tag_sf;
    int                index;
    bit                found;
    bit [WSFSETIDX-1:0] set_index;
    bit vb_entry_moved_to_sf;
        
    tag_sf = get_tag_sf_handle(sfid);
    set_index = set_index_for_cacheline(cacheline_addr, sfid);
    found = tag_sf.entry_exists_in_victim_buffer(cacheline_addr, index, vb_entry_moved_to_sf);

    if(vb_entry_moved_to_sf==0) begin
        if ((tag_sf.recall_entry.entry_status == ENTRY_VALID) && (tag_sf.recall_entry.cacheline == cacheline_addr)) begin
            tag_sf.recall_entry.entry_status = ENTRY_INVALID; 
        end else if (found == 0) begin
            `uvm_error("DIRM MGR", $sformatf("entry to be deleted not found in VB : set_index %0h : SF%0d : Cacheline %0h",set_index,sfid,cacheline_addr))
        end else begin
            tag_sf.m_victim_buffer.delete(index);
            //push back entry from recall_entry into vctb since there is space now.
            if (tag_sf.recall_entry.entry_status == ENTRY_VALID) begin
                tag_sf.m_victim_buffer.push_back(tag_sf.recall_entry);
                tag_sf.recall_entry.entry_status = ENTRY_INVALID;
                //populate_recall_list();
            end
            //populate_vb_list();
        end
    end

    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", $psprintf("VB%0d DEPTH: %0d %s", tag_sf.filter_id, tag_sf.get_vctb_depth(), tag_sf.conv_vctb_info2string()), UVM_MEDIUM)
endfunction: delete_entry_in_vb

//******************recall_list contains recall_entry flop across all filters********************
function void directory_mgr::populate_tf_list(bit [WSMIADDR:0] addr_w_sec_i);
    
    tag_snoop_filter   tag_sf;
    tag_snoop_filter_t hit_entry;
    recall_entry_t     tflist_entry;
    bit [WSMIADDR:0]   offset_aligned_addr_w_sec;
    string s;
    bit [WSFSETIDX-1:0] set_index;

    //clear outputs
    bit vhit = 0;
    int ign_vhit_idx = 0;
    int ign_evict_way, ign_hit_way;

    offset_aligned_addr_w_sec = offset_align_cacheline(addr_w_sec_i);

    tf_list.delete();
    for(int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin 
        tag_sf    = get_tag_sf_handle(sfid);
        set_index = set_index_for_cacheline(offset_aligned_addr_w_sec, sfid);
        if (tag_sf.snoop_filter_hit(set_index, offset_aligned_addr_w_sec, hit_entry, ign_hit_way, vhit, ign_vhit_idx)) begin
            if (vhit == 0) begin 
                tflist_entry.recall_entry  = hit_entry;
                tflist_entry.tag_filter_id = sfid;
                tf_list.push_back(tflist_entry);
            end
        end
    end
    
    if(tf_list.size() == 0)
        $sformat(s, "%s tf_list data structure is empty", s);

    foreach(tf_list[ridx]) begin
        hit_entry = tf_list[ridx].recall_entry;
        tag_sf    = get_tag_sf_handle(tf_list[ridx].tag_filter_id);

        $sformat(s, "%s tf_list[%0d] pkt that can be potentially recalled in filter_id:%0d : %s", s, ridx, tf_list[ridx].tag_filter_id, tag_sf.conv_sf_info2string(hit_entry, -1));
    end

    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", s, UVM_MEDIUM)


endfunction: populate_tf_list
//******************recall_list contains recall_entry flop across all filters********************
function void directory_mgr::populate_recall_list();

    tag_snoop_filter   tag_sf;
    recall_entry_t     recalllist_entry;
    tag_snoop_filter_t recall_entry;
    string s;
    
//    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
//      tag_sf = get_tag_sf_handle(i);
//        `uvm_info("REC_REQ RECALL ENTRY DATA", $psprintf("sfid:%0d recall pkt:%s", i, tag_sf.conv_sf_info2string(tag_sf.recall_entry, -1)), UVM_MEDIUM)
//    end 

    recall_list.delete();
    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        tag_sf = get_tag_sf_handle(i);
        //`uvm_info("RECALL ENTRY DBG", $psprintf("sfid:%0d recall pkt:%s", i, conv_sf_info2string(tag_sf.recall_entry, -1)), UVM_MEDIUM)
        if (tag_sf.recall_entry.entry_status == ENTRY_VALID) begin
            recalllist_entry.recall_entry  = tag_sf.recall_entry;
            recalllist_entry.tag_filter_id = i;
            recall_list.push_back(recalllist_entry);
        end
    end
    
    if(recall_list.size() == 0)
        $sformat(s, "%s recall_list data structure is empty", s);

    foreach(recall_list[ridx]) begin
        recall_entry = recall_list[ridx].recall_entry;
        tag_sf = get_tag_sf_handle(recall_list[ridx].tag_filter_id);

        $sformat(s, "%s recall_list[%0d] pkt that can be potentially recalled: %s", s, ridx, tag_sf.conv_sf_info2string(recall_entry, -1));
    end

    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", s, UVM_MEDIUM)

endfunction: populate_recall_list

//******************vb_list contains all entries in VB across all filters********************
function void directory_mgr::populate_vb_list();
    tag_snoop_filter   tag_sf;
    recall_entry_t     vblist_entry;
    tag_snoop_filter_t vb_entry;
    string s;

    vb_list.delete();
    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        tag_sf = get_tag_sf_handle(i);
        foreach(tag_sf.m_victim_buffer[ridx]) begin

            vblist_entry.recall_entry = tag_sf.m_victim_buffer[ridx];
            vblist_entry.tag_filter_id = i;
            vb_list.push_back(vblist_entry);
        end 
    end
    
    if(vb_list.size() == 0)
        $sformat(s, "%s vb_list data structure is empty", s);

    foreach(vb_list[ridx]) begin
        vb_entry = vb_list[ridx].recall_entry;
        tag_sf = get_tag_sf_handle(vb_list[ridx].tag_filter_id);

        $sformat(s, "%s vb_list[%0d] vb_list pkt that can be potentially recalled: %s", s, ridx, tag_sf.conv_sf_info2string(vb_entry, -1));
    end

    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", s, UVM_MEDIUM)

endfunction: populate_vb_list

//*****************************************************************
function void directory_mgr::revert_model_on_retryrsp(bit [WSMIADDR : 0] cacheline, int sfid);

    bit [31:0] set_index;
    int found_way;
    tag_snoop_filter tag_sf;
    bit none_valid = 1;
    
    tag_sf = get_tag_sf_handle(sfid);
    cacheline = offset_align_cacheline(cacheline);
    set_index = set_index_for_cacheline(cacheline, sfid);

    `uvm_info("DIRM MGR", $psprintf("fn:revert_model_on_retryrsp-- SFID:%0d cacheline:0x%0h set_index:0x%0h hit:%0d", sfid, cacheline, set_index, tag_sf.entry_exists_in_tag_filter(set_index, cacheline, found_way)), UVM_MEDIUM)
    if (tag_sf.entry_exists_in_tag_filter(set_index, cacheline, found_way)) begin
        //`uvm_error("DIRM MGR", $psprintf("fn:revert_model_on_retryrsp: SFID:%0d cacheline:0x%0h set_index:0x%0h way:%0d %0s", sfid, cacheline, set_index, found_way, tag_sf.sf_segment_details(1'b1, set_index, , cacheline)))
        for(int i = 0; i < tag_sf.get_num_cacheing_agents(); i++) begin
            if (tag_sf.sf_cache[set_index][found_way].validity[i] == True) begin
                none_valid = 0;
                break;
            end
        end
        if ((none_valid == 1) && (found_way == (tag_sf.sf_cache[set_index].size() - 1))) begin
            tag_sf.sf_cache[set_index].delete(found_way);
        end
        `uvm_info("DIRM MGR", $psprintf("fn:revert_model_on_retryrsp-- SFID:%0d cacheline:0x%0h set_index:0x%0h hit:%0d", sfid, cacheline, set_index, tag_sf.entry_exists_in_tag_filter(set_index, cacheline, found_way)), UVM_MEDIUM)
    end

endfunction: revert_model_on_retryrsp

function void directory_mgr::print_all_ways(bit [WSMIADDR:0] m_cacheline);

    int m_sfid;
    string msg;
    tag_snoop_filter m_tag_sf;
    bit [31:0] set_index;
    bit [WSMIADDR:0] tmp_addr;

    tmp_addr  = offset_align_cacheline(m_cacheline);
    $sformat(msg, "Detailed info for cacheline:0x%0h", tmp_addr);

    for(m_sfid = 0; m_sfid <ncoreConfigInfo::NUM_SF; m_sfid++) begin
        if((ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") && is_snoop_filter_en(m_sfid)) begin

            set_index = set_index_for_cacheline(tmp_addr, m_sfid);
            m_tag_sf  = get_tag_sf_handle(m_sfid);

            //Tag Filter Info & Victim bufferinfo
            $sformat(msg, "%s %s", msg, m_tag_sf.conv_tag_info2string(set_index));
            $sformat(msg, "%s %s", msg, m_tag_sf.conv_vctb_info2string());
        end
   end
    
   if(m_dirm_dbg)
     `uvm_info("DIRM MGR", msg, UVM_MEDIUM)
endfunction: print_all_ways

//**************************************************************************************************
function void directory_mgr::print_exp_recall_entry();

    tag_snoop_filter_t recall_entry;
    tag_snoop_filter   m_tag_sf;

    string s;

    if(recall_list.size() == 0)
        $sformat(s, "%s Nothing to recall in recall_list data structure", s);

    foreach(recall_list[ridx]) begin
        recall_entry   = recall_list[ridx].recall_entry;
        m_tag_sf = get_tag_sf_handle(recall_list[ridx].tag_filter_id);

        $sformat(s, "%s {EXP} recall pkt: %s", s, m_tag_sf.conv_sf_info2string(recall_entry, -1));
    end

    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", s, UVM_MEDIUM)

endfunction: print_exp_recall_entry

//************************************************************************
function void directory_mgr::flush_all_entries(int sfid);
    tag_snoop_filter m_tag_sf;

    if(ncoreConfigInfo::snoop_filters_info[sfid].filter_type == "TAGFILTER") begin
        m_tag_sf = get_tag_sf_handle(sfid);
        m_tag_sf.flush_all_entries();

        if(m_dirm_dbg)
            `uvm_info("DIRM MGR",
                $psprintf("Flushed all entries in SF:%0d", sfid), UVM_MEDIUM)
    end
endfunction: flush_all_entries

//Method to Enable/Disable snoop filter depending on register DIRUSFEN 
function void directory_mgr::dirm_sfen_reg_status(bit [31:0] sf_status);
    tag_snoop_filter m_tag_sf;

    foreach(ncoreConfigInfo::snoop_filters_info[ridx]) begin

        if(ncoreConfigInfo::snoop_filters_info[ridx].filter_type == "TAGFILTER") begin
            m_tag_sf = get_tag_sf_handle(ridx);

            if(m_tag_sf.get_snoop_filter_status()) begin
                if(!sf_status[ridx]) begin
                    if(m_dirm_dbg)
                        `uvm_info("DIRM MGR", $psprintf("sfid:%0d is powered down", ridx), UVM_MEDIUM)

                    //Disable Snoop Filter
                    m_tag_sf.set_snoop_filter_status(1'b0);
                end
            end else begin
                if(sf_status[ridx]) begin
                     //Enable Snoop Filter
                     m_tag_sf.set_snoop_filter_status(1'b1);
                end
            end
        end
    end
endfunction: dirm_sfen_reg_status

//Method disables tag snoop filter if uncorrectable error is observed
function void directory_mgr::sf_disable_on_uncorr_err(bit [31:0] sf_disable);
    tag_snoop_filter m_tag_sf;

    foreach(ncoreConfigInfo::snoop_filters_info[ridx]) begin
        if(ncoreConfigInfo::snoop_filters_info[ridx].filter_type == "TAGFILTER") begin
            m_tag_sf = get_tag_sf_handle(ridx);

            if(m_tag_sf.get_snoop_filter_status()) begin
                if(!sf_disable[ridx]) begin
                    if(m_dirm_dbg)
                        `uvm_info("DIRM MGR", $psprintf("sfid:%0d is powered down", ridx), UVM_MEDIUM)

                    //Disable Snoop Filter
                    m_tag_sf.set_snoop_filter_status(1'b0);
                end
            end
        end
    end
endfunction: sf_disable_on_uncorr_err

//Status of Snoop F r
function bit directory_mgr::is_snoop_filter_en(int id);
    tag_snoop_filter m_tag_sf;
    bit status;

    if(ncoreConfigInfo::snoop_filters_info[id].filter_type == "TAGFILTER") begin
        m_tag_sf = get_tag_sf_handle(id);
        status   = m_tag_sf.get_snoop_filter_status();
       
    end else begin
        status = 1'b1;
    end
    return(status);
endfunction: is_snoop_filter_en

//Method does a lookup into SF specified and returns way and
//sf segment details if it is a hit. Read only method,
//does not change any details related to SF segment
function bit directory_mgr::addr_hit_in_tag_filter(
                bit [WSMIADDR:0] offset_aligned_addr_w_sec,
                int m_sfid,
                output int way_alloc,
                inout tag_snoop_filter_t m_lkup);

    tag_snoop_filter m_tag_sf;
    bit [31:0] set_index;
   // bit [63:0] tmp_addr;

    //tmp_addr  = offset_align_cacheline(m_addr);
    set_index = set_index_for_cacheline(offset_aligned_addr_w_sec, m_sfid);
    m_tag_sf  = get_tag_sf_handle(m_sfid);
    
    if(m_tag_sf.tag_filter_lookup(set_index, offset_aligned_addr_w_sec, way_alloc, m_lkup)) begin
        if(m_dirm_dbg) begin
            `uvm_info("DIRM MGR", $psprintf("cacheline:0x%x found in sfid: %0d", offset_aligned_addr_w_sec, m_sfid), UVM_MEDIUM)
//                for(int j = 0; j < m_lkup.ownership.size(); j++) begin
//                  `uvm_info("DBG", $psprintf("fn: addr_hit_in_tag_filter sfid: %0d cid:%0d o:%0s v:%0s", m_sfid, j, m_lkup.ownership[j], m_lkup.validity[j]), UVM_MEDIUM)
//                end
        end
        return(1'b1);
    end else begin
        if(m_dirm_dbg) begin
            `uvm_info("DIRM MGR", $psprintf("cacheline:0x%x not found in sfid: %0d", offset_aligned_addr_w_sec, m_sfid), UVM_MEDIUM)
        end
        return(1'b0);
    end
        
endfunction: addr_hit_in_tag_filter

//Method returns cacheline with offset masked
function bit [WSMIADDR:0] directory_mgr::offset_align_cacheline(bit [WSMIADDR:0] m_addr_w_sec);
    bit [WSMIADDR:0] bit_mask_const;
    bit [WSMIADDR:0] tmp_addr;

    bit_mask_const = 'h1_FFFF_FFFF_FFFF << ncoreConfigInfo::WCACHE_OFFSET;
    tmp_addr = m_addr_w_sec & bit_mask_const;

//    if(m_dirm_dbg)
//        `uvm_info("DIRM MGR", $psprintf("offset aligned cacheline:%h", tmp_addr), UVM_MEDIUM)

    return(tmp_addr);
endfunction: offset_align_cacheline

//Method returns set index for given cacheline
//NOTE: always call this method with cacheline offset mask
function bit [31:0] directory_mgr::set_index_for_cacheline( bit [WSMIADDR:0] m_addr, int m_sfid);
    bit [31:0] set_index;
    bit result;

    foreach(ncoreConfigInfo::sf_set_sel[m_sfid].pri_bits[idx]) begin
        result = m_addr[ncoreConfigInfo::sf_set_sel[m_sfid].pri_bits[idx]];
        foreach(ncoreConfigInfo::sf_set_sel[m_sfid].sec_bits[idx,idx2]) begin
            result = result ^ m_addr[ncoreConfigInfo::sf_set_sel[m_sfid].sec_bits[idx][idx2]];
        end
        set_index[idx] = result;
    end
//    if(m_dirm_dbg) begin
//        `uvm_info("DIRM MGR", $psprintf("m_sfid:0x%0h set_index:0x%h", m_sfid, set_index), UVM_MEDIUM)
//    end

    return(set_index);
endfunction: set_index_for_cacheline

//************************************************************************
function void directory_mgr::construct_lookup_vectors( sf_info_t                       sf_info_i[$],
                                                     output bit [ncoreConfigInfo::NUM_CACHES-1:0] olv_o,  
                                                     output bit [ncoreConfigInfo::NUM_CACHES-1:0] slv_o, 
                                                     output bit [WSFWAYVEC-1:0]                            way_vec_o);

    tag_snoop_filter tag_sf;
    int startBit = 0;

    for (int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        tag_sf = get_tag_sf_handle(sfid);
        for (int cacheid = 0; cacheid < ncoreConfigInfo::NUM_CACHES; cacheid++) begin
            if (ncoreConfigInfo::cacheid_assoc_with_sfid(sfid, cacheid) == 1) begin
                int ridx = ncoreConfigInfo::rel_indx_within_sf(sfid, cacheid);
                if (sf_info_i[sfid].vld == 0) begin
                    olv_o[cacheid] = 0; 
                    slv_o[cacheid] = 0; 
                end else begin
                    if(sf_info_i[sfid].ownership[ridx] == True) begin
                        olv_o[cacheid] = 1'b1;
                        slv_o[cacheid] = 1'b0;
                    end else if(sf_info_i[sfid].validity[ridx] == True) begin
                        olv_o[cacheid] = 1'b0;
                        slv_o[cacheid] = 1'b1;
                    end else if((sf_info_i[sfid].ownership[ridx] == False) && (sf_info_i[sfid].validity[ridx] == False)) begin
                        olv_o[cacheid] = 1'b0;
                        slv_o[cacheid] = 1'b0;
                    end else begin
                        `uvm_fatal("DIRM MGR", "Undefined state for explictowner tag filter")
                    end
                end 
            end //cacheid_assoc_with_sfid == 1
        end //loop over NUM_CACHES
    end //loop_over NUM_SF

    //Calculating way_vec
    for (int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        tag_sf = get_tag_sf_handle(sfid);
        if (sf_info_i[sfid].vld == 1) begin
            way_vec_o = way_vec_o | (1 << (sf_info_i[sfid].way + startBit));
        end 
        startBit = startBit + tag_sf.num_ways;
    end 

    if(m_dirm_dbg)
        `uvm_info("DIRM MGR", $psprintf("fn:construct_lookup_vectors final olv:0x%0h slv:0x%0h way_vec:0x%0h", olv_o, slv_o, way_vec_o), UVM_MEDIUM)

endfunction: construct_lookup_vectors


//Method returns the DS cacheline_sf_lkup_info_t for all snoop filters
function void directory_mgr::extract_sf_hit_miss_info(
    bit [WSMIADDR:0] offset_aligned_addr_w_sec,
    inout cacheline_sf_lkup_info_t sf_lkup_info[$]);
    
    tag_snoop_filter_t m_info;
    int way_alloc;
    //bit [63:0] tmp_addr;

    //tmp_addr     = offset_align_cacheline(m_cacheline);
    sf_lkup_info = {};
    for(int i = 0; i < ncoreConfigInfo::NUM_SF; i++) begin
        cacheline_sf_lkup_info_t m_lkup_info;

        if((ncoreConfigInfo::snoop_filters_info[i].filter_type == "TAGFILTER") && is_snoop_filter_en(i)) begin

            m_lkup_info.name      = ncoreConfigInfo::snoop_filters_info[i].tag_sf_type;
            m_lkup_info.filter_en = 1'b1;

            if(addr_hit_in_tag_filter(offset_aligned_addr_w_sec, i, way_alloc, m_info)) begin
                m_lkup_info.sf_hit = 1'b1;
                m_lkup_info.way_allocated = way_alloc;
                
                for(int j = 0; j < m_info.ownership.size(); j++) begin
                    //`uvm_info("DBG", $psprintf("sfid: %0d cid:%0d o:%0s v:%0s", i, j, m_info.ownership[j], m_info.validity[j]), UVM_MEDIUM)
                    m_lkup_info.ownership[j] = m_info.ownership[j];
                    m_lkup_info.validity[j] = m_info.validity[j];
                end
            end
        end else begin //For NULL filter

            if(ncoreConfigInfo::snoop_filters_info[i].filter_type == "NULL") begin
                m_lkup_info.name      = "NULL";
                m_lkup_info.filter_en = 1'b1;
            end else begin
                m_lkup_info.name      = ncoreConfigInfo::snoop_filters_info[i].tag_sf_type;
                m_lkup_info.filter_en = 1'b0;
            end
        end //for NULL filter
        sf_lkup_info.push_back(m_lkup_info);
    end

    if(m_dirm_dbg) begin
         string s;
        for(int i = 0; i < sf_lkup_info.size(); i++) begin
            $sformat(s, "%s\n", s);
            $sformat(s, "%s filter:%s id:%0d filter_en:%0b way_en:%b way:%0d", s,
                sf_lkup_info[i].name, i, sf_lkup_info[i].filter_en, sf_lkup_info[i].sf_hit, sf_lkup_info[i].way_allocated);
            foreach(sf_lkup_info[i].ownership[ridx]) begin
                $sformat(s, "%s ownership:%s validity:%s", s, sf_lkup_info[i].ownership[ridx].name(), sf_lkup_info[i].validity[ridx].name());
            end
        end
        `uvm_info("DIRM MGR", $psprintf("sf lookup info for cacheline:0x%x %s", offset_aligned_addr_w_sec, s), UVM_MEDIUM)
    end

endfunction: extract_sf_hit_miss_info

function bit directory_mgr::eos_filter_exists(
     cacheline_sf_lkup_info_t m_sf_lkup_info[$]);

    bit status;

    foreach(m_sf_lkup_info[ridx]) begin

        if((m_sf_lkup_info[ridx].name == "EXPLICITOWNER") &&
            (m_sf_lkup_info[ridx].filter_en)) begin
            status = 1'b1;
            break;
        end
    end

    return(status);
endfunction: eos_filter_exists

function void directory_mgr::assign_eos_lkup_vectors(
    int m_sfid,
    cacheline_sf_lkup_info_t m_lkup_info,
    inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv,
    inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_slv);

    //Sanity check
    if(ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type != "TAGFILTER")
        `uvm_fatal("DIRM MGR", "Method expects filter type to be TAGFILTER")

    for(int i = 0; i < ncoreConfigInfo::NUM_CACHES; i++) begin
        if(ncoreConfigInfo::cacheid_assoc_with_sfid(m_sfid, i)) begin
            int ridx;

            if(m_dirm_dbg)
                `uvm_info("DIRM SCB", $psprintf("i:%0d ridx:%0d", i, ridx), UVM_MEDIUM)
            ridx = ncoreConfigInfo::rel_indx_within_sf(m_sfid, i);

            if(m_lkup_info.ownership[ridx] == True) begin
                m_olv[i] = 1'b1;
                m_slv[i] = 1'b0;
            end else if(m_lkup_info.validity[ridx] == True) begin
                m_olv[i] = 1'b0;
                m_slv[i] = 1'b1;
            end else if((m_lkup_info.ownership[ridx] == False) && (m_lkup_info.validity[ridx] == False)) begin
                m_olv[i] = 1'b0;
                m_slv[i] = 1'b0;
            end else begin
                `uvm_fatal("DIRM MGR", "Undefined state for explictowner tag filter")
            end
        end
    end
    
    if(m_dirm_dbg) 
        `uvm_info("DIRM MGR", $psprintf("fn: assign_eos_lkup_vectors sfid:%0d m_olv:0x%h m_slv:0x%h", m_sfid, m_olv, m_slv), UVM_MEDIUM)
endfunction: assign_eos_lkup_vectors

function void directory_mgr::assign_pv_lkup_vectors(
    int m_sfid,
    bit owner_exists,
    cacheline_sf_lkup_info_t m_lkup_info,
    inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv,
    inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_slv);

    `uvm_fatal("DIRM MGR", "For ncore 3.0 we should never get to fn: assign_pv_lkup_vectors")
    
    //Sanity check
    if(ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type != "TAGFILTER")
        `uvm_fatal("DIRM MGR", "Method expects filter type to be TAGFILTER")

    for(int i = 0; i < ncoreConfigInfo::NUM_CACHES; i++) begin
        if(ncoreConfigInfo::cacheid_assoc_with_sfid(m_sfid, i)) begin
            int ridx;

            if(m_dirm_dbg)
                `uvm_info("DIRM SCB", $psprintf("i:%0d ridx:%0d", i, ridx), UVM_MEDIUM)
            ridx = ncoreConfigInfo::rel_indx_within_sf(m_sfid, i);

            if(owner_exists) begin
//                if(m_lkup_info.validity[ridx] == True || m_lkup_info.validity[ridx] == Uncertain) begin
//                    m_olv[i] = 1'b0;
//                    m_slv[i] = 1'b1;
//                end
            end else begin
//                if(m_lkup_info.validity[ridx] == True || m_lkup_info.validity[ridx] == Uncertain) begin
//                    m_olv[i] = 1'b1;
//                    m_slv[i] = 1'b1;
//                end
            end
        end
    end

    if(m_dirm_dbg) begin
        `uvm_info("DIRM MGR", $psprintf("sfid:%0d potential_owner:%b m_olv:0x%h m_slv:0x%h",
            m_sfid, owner_exists, m_olv, m_slv), UVM_MEDIUM)
    end
endfunction: assign_pv_lkup_vectors

function void directory_mgr::assign_null_lkup_vectors(
    int m_sfid,
    bit owner_exists,
    cacheline_sf_lkup_info_t m_lkup_info,
    inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv,
    inout bit [ncoreConfigInfo::NUM_CACHES-1:0] m_slv);

    //Sanity check
    `uvm_fatal("DIRM MGR", "For ncore 3.0 we should never get to fn: assign_null_lkup_vectors")
    if((ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type != "NULL") &&
        is_snoop_filter_en(m_sfid))
        `uvm_fatal("DIRM MGR", "Method expects filter type to be NULL")

    for(int i = 0; i < ncoreConfigInfo::NUM_CACHES; i++) begin
        if(ncoreConfigInfo::cacheid_assoc_with_sfid(m_sfid, i)) begin
            int ridx;

            if(m_dirm_dbg)
                `uvm_info("DIRM SCB", $psprintf("i:%0d ridx:%0d", i, ridx), UVM_MEDIUM)
            ridx = ncoreConfigInfo::rel_indx_within_sf(m_sfid, i);

            if(owner_exists) begin
                m_olv[i] = 1'b0;
                m_slv[i] = 1'b1;
            end else begin
                m_olv[i] = 1'b1;
                m_slv[i] = 1'b0;
            end
        end
    end
endfunction: assign_null_lkup_vectors

function bit directory_mgr::potential_owner_exists( bit [ncoreConfigInfo::NUM_CACHES-1:0] m_olv);

    bit status;

    if(count_bits(m_olv) > 1) begin
        `uvm_fatal("DIRM MGR", "Illegal, only one cacheing agent can be represented has owner")
    end

    if(count_bits(m_olv)) begin
        status = 1'b1;
        `uvm_info("DIRM MGR", $psprintf("owner_exists m_olv:0x%0h", m_olv), UVM_MEDIUM)
    end

    return(status);
endfunction: potential_owner_exists

function void directory_mgr::assign_ownership_validity_status(
    int sfid_i,
    int cacheid_i,
    bit [ncoreConfigInfo::NUM_CACHES-1:0] ocv_i,
    bit [ncoreConfigInfo::NUM_CACHES-1:0] scv_i,
    output dir_seg_status_t ownership_o,
    output dir_seg_status_t validity_o);
    
    if (    (ncoreConfigInfo::snoop_filters_info[sfid_i].filter_type == "TAGFILTER") 
         && (ncoreConfigInfo::snoop_filters_info[sfid_i].tag_sf_type == "EXPLICITOWNER")
         && (is_snoop_filter_en(sfid_i) == 1)
       ) begin

         //check if more than one cacheing agent associated to EOS filter is set to 1
         if(count_bits(ocv_i) > 1) begin
             `uvm_fatal("DIRM MGR", "Illegal, only one cacheing agent can be represented has owner")
         end
         
         if(ocv_i[cacheid_i] && scv_i[cacheid_i]) begin
             string m = "{ocv, scv} {set, set} Illegal combination for EOS type of filter";
             `uvm_fatal("DIRM MGR", m)
         end

         if(ocv_i[cacheid_i]) begin
             ownership_o = True;
             validity_o  = True;
         end else begin
             if(scv_i[cacheid_i]) begin
                 ownership_o = False;
                 validity_o  = True;
             end else begin
                 ownership_o = False;
                 validity_o  = False;
             end
         end
    end 
    
    //`uvm_info("DIRM SCB", $psprintf("ownership:%0p validity:%0p cidx:%0d", ownership_o, validity_o, cacheid_i), UVM_MEDIUM)
    
endfunction: assign_ownership_validity_status


function int directory_mgr::count_bits(bit [31:0] val);
    int count;

    count = 0;
    while(val !=0) begin
        if(val[0])
           count++;
        val = val >>1;
    end

    return(count);
endfunction: count_bits

//returns 1 if entry is valid in SF and that ownership/validity status must be retained
//else 0 indicating that the entry in SF is invalidated
function bit directory_mgr::sf_entry_validity(
                 bit [ncoreConfigInfo::NUM_CACHES-1:0] m_ocv,
                 bit [ncoreConfigInfo::NUM_CACHES-1:0] m_scv,
                 int sidx,
                  int assoc_cacheids[$]);
    bit status;

    foreach(assoc_cacheids[ridx]) begin
        if((m_ocv[assoc_cacheids[ridx]]) || (m_scv[assoc_cacheids[ridx]])) begin
            status = 1'b1;
            break;
        end
    end

    return(status);
endfunction: sf_entry_validity

function tag_snoop_filter directory_mgr::get_tag_sf_handle(int m_sfid);

    tag_snoop_filter m_tag_sf;

    if(!$cast(m_tag_sf, m_snoop_filterq[m_sfid])) 
        `uvm_fatal("DIRM MGR", "unable to cast")

    return(m_tag_sf);
endfunction: get_tag_sf_handle

//////////////////////////////////////////////////////////////
//Helper Methods for Simullus to generate intersting senarios
//////////////////////////////////////////////////////////////
function void directory_mgr::get_reqaiu_valid_tagf_cachelines(
    int req_aiuid,
    inout cachelines_q m_addr_list);

    int m_sfid;
    int ridx;
    tag_snoop_filter m_tag_sf;

    m_addr_list = '{};
    m_sfid = ncoreConfigInfo::get_snoopfilter_id(req_aiuid);

    if(m_sfid == -1) begin
        if(m_dirm_dbg) begin
            `uvm_info("DIRM MGR", $psprintf("req_aiu:%0d is not caching agent",
               req_aiuid), UVM_MEDIUM)
        end
    end else begin
        if((ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") &&
            is_snoop_filter_en(m_sfid)) begin

            ridx = ncoreConfigInfo::rel_indx_within_sf(m_sfid,
                       ncoreConfigInfo::get_cache_id(req_aiuid));

            m_tag_sf = get_tag_sf_handle(m_sfid);
            m_tag_sf.get_valid_tag_filter_cachelines(
                ridx,
                m_addr_list);
        end
    end

endfunction: get_reqaiu_valid_tagf_cachelines

function void directory_mgr::get_reqaiu_valid_vctb_cachelines(
    int req_aiuid,
    inout cachelines_q m_addr_list);

    int m_sfid;
    int ridx;
    tag_snoop_filter m_tag_sf;

    m_addr_list = '{};
    m_sfid = ncoreConfigInfo::get_snoopfilter_id(req_aiuid);
    if(m_sfid == -1) begin
        if(m_dirm_dbg) begin
            `uvm_info("DIRM MGR", $psprintf("req_aiu:%0d is not caching agent",
               req_aiuid), UVM_MEDIUM)
        end
    end else begin
        if((ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") &&
            is_snoop_filter_en(m_sfid)) begin

            ridx = ncoreConfigInfo::rel_indx_within_sf(m_sfid,
                       ncoreConfigInfo::get_cache_id(req_aiuid));

            m_tag_sf = get_tag_sf_handle(m_sfid);
            m_tag_sf.get_valid_victim_buffer_cachelines(
                ridx, m_addr_list);
        end
    end
endfunction: get_reqaiu_valid_vctb_cachelines

function void directory_mgr::get_reqaiu_invalid_cachelines(
    int req_aiuid,
    inout cachelines_q m_addr_list);

    int m_sfid;
    int ridx;
    tag_snoop_filter m_tag_sf;

    m_addr_list = '{};
    m_sfid = ncoreConfigInfo::get_snoopfilter_id(req_aiuid);

    if(m_sfid == -1) begin
        if(m_dirm_dbg) begin
            `uvm_info("DIRM MGR", $psprintf("req_aiu:%0d is not caching agent",
               req_aiuid), UVM_MEDIUM)
        end
    end else begin
        if((ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") &&
            is_snoop_filter_en(m_sfid)) begin

            ridx = ncoreConfigInfo::rel_indx_within_sf(m_sfid,
                       ncoreConfigInfo::get_cache_id(req_aiuid));
            
            m_tag_sf = get_tag_sf_handle(m_sfid);
            m_tag_sf.get_invalid_tag_filter_cachelines(
                ridx, m_addr_list);
        end
    end
endfunction: get_reqaiu_invalid_cachelines

function void directory_mgr::get_valid_entries_info(
    int sf_id,
    inout bit [WSFSETIDX-1:0] set_indexes_q[$],
    inout int ways_q[$],
    inout cachelines_q m_addr_list);

    tag_snoop_filter m_tag_sf;

    set_indexes_q = '{};
    ways_q        = '{};
    m_addr_list   = '{};
    if(ncoreConfigInfo::snoop_filters_info[sf_id].filter_type == "TAGFILTER") begin

        m_tag_sf = get_tag_sf_handle(sf_id);
        m_tag_sf.get_valid_entries_info(set_indexes_q, ways_q, m_addr_list);    
    end

endfunction: get_valid_entries_info

function void directory_mgr::get_invalid_entries_info(
    int sf_id,
    inout bit [WSFSETIDX-1:0] set_indexes_q[$],
    inout int ways_q[$],
    inout cachelines_q m_addr_list);

    tag_snoop_filter m_tag_sf;

    set_indexes_q = '{};
    ways_q        = '{};
    m_addr_list   = '{};
    if(ncoreConfigInfo::snoop_filters_info[sf_id].filter_type == "TAGFILTER") begin

        m_tag_sf = get_tag_sf_handle(sf_id);
        m_tag_sf.get_invalid_entries_info(set_indexes_q, ways_q, m_addr_list);    
    end

endfunction: get_invalid_entries_info

//////////////////////////////////////////////////////////////
//Coverage collection
//////////////////////////////////////////////////////////////
function void directory_mgr::print_cov_data();
    
    `uvm_info("DM_COV", $psprintf("vctb_hit_in_all_sf:%0b vctb_hit_in_multiple_sf:%0b tagf_hit_in_all_sf:%0b tagf_hit_in_multiple_sf:%0b vctb_hit_tagf_hit:%0b",
                obsrvd_vctb_hit_in_all_sf,
                obsrvd_vctb_hit_in_multiple_sf,
                obsrvd_tagf_hit_in_all_sf,    
                obsrvd_tagf_hit_in_multiple_sf,
                obsrvd_vctb_hit_tagf_hit), UVM_MEDIUM);

endfunction: print_cov_data

function void directory_mgr::dm_lkprsp_checks(int home_filter,  dm_seq_item lkprsp);

    tag_snoop_filter tag_sf;
    bit              sf_hit     = 0;
    bit              alloc_miss = 0;

    for (int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        tag_sf = get_tag_sf_handle(sfid);
        for (int cacheid = 0; cacheid < ncoreConfigInfo::NUM_CACHES; cacheid++) begin
            if (ncoreConfigInfo::cacheid_assoc_with_sfid(sfid, cacheid) == 1) begin
                if (lkprsp.m_sharer_vec[cacheid] == 1)
                    sf_hit = 1;
            end
        end
        
        //#Check.DCE.dm_vbhit_sfhit
        if (    lkprsp.m_rtl_vbhit_sfvec[sfid] == 1
             && sf_hit == 0)
                `uvm_error("DM_LKP_RSP_ERROR", $psprintf("VB hit in sfid:%0d but lkp_rsp indicates a miss", sfid))
        
        //#Check.DCE.dm_vbhit_dm_write
        if (    lkprsp.m_rtl_vbhit_sfvec[sfid] == 1
             && lkprsp.m_wr_required == 0) 
                `uvm_error("DM_LKP_RSP_ERROR", $psprintf("VB hit in sfid:%0d but lkp_rsp does not indicate a dm write", sfid))

        //#Check.DCE.dm_CmdRsp_VBSwapWay
        if (    lkprsp.m_rtl_vbhit_sfvec[sfid] == 1
             && get_waynum(sfid, lkprsp.m_way_vec_or_mask) == -1)
                `uvm_error("DM_LKP_RSP_ERROR", $psprintf("VB hit in sfid:%0d but lkp_rsp does not indicate an alloc way", sfid))

        //#Check.DCE.dm_CmdRspNonAllocReqMissWayVec
        if (    (sf_hit == 0)                               //sf miss
             && (home_filter != sfid)) begin                //not home filter
            if (get_waynum(sfid, lkprsp.m_way_vec_or_mask) != -1)
                `uvm_error("DM_LKP_RSP_ERROR", $psprintf("Non alloc miss in sfid:%0d but lkp_rsp incorrectly indicates way:0x%0d", sfid, get_waynum(sfid, lkprsp.m_way_vec_or_mask)))
        end
    end//loop through SFs
endfunction: dm_lkprsp_checks

function void directory_mgr::dm_lkprsp_sf_coverage(int home_filter,  dm_seq_item lkprsp);
    
    tag_snoop_filter tag_sf;
    `uvm_info("DIRM MGR", $psprintf("dm_lkprsp_sf_coverage hf:%0d", home_filter), UVM_MEDIUM)
    for (int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        tag_sf = get_tag_sf_handle(sfid);
        //reset everything
        tag_sf.obsrvd_vctb_hit = 0;
        tag_sf.obsrvd_tagf_hit = 0;
        tag_sf.obsrvd_home_filter = 0;
        tag_sf.obsrvd_alloc_miss = 0;
        tag_sf.obsrvd_alloc_evct_way = -1;
        tag_sf.obsrvd_hit_swap_way = -1;

        if (lkprsp.m_rtl_vbhit_sfvec[sfid] == 1)
            tag_sf.obsrvd_vctb_hit = 1;
        for (int cacheid = 0; cacheid < ncoreConfigInfo::NUM_CACHES; cacheid++) begin
            if (ncoreConfigInfo::cacheid_assoc_with_sfid(sfid, cacheid) == 1) begin
                if (lkprsp.m_sharer_vec[cacheid] == 1 && lkprsp.m_rtl_vbhit_sfvec[sfid] != 1) begin
                    tag_sf.obsrvd_tagf_hit = 1;
                end
                if (sfid == home_filter) begin //allocating request
                    tag_sf.obsrvd_home_filter = 1;
                    if (lkprsp.m_sharer_vec[cacheid] == 0)
                        tag_sf.obsrvd_alloc_miss = 1;
                    else 
                        tag_sf.obsrvd_alloc_miss = 0;
                end
            end 
        end //loop through cacheids in sharer_vec
        if (tag_sf.obsrvd_alloc_miss == 1) begin 
            tag_sf.obsrvd_alloc_evct_way = get_waynum(sfid, lkprsp.m_way_vec_or_mask);
        end else begin
            tag_sf.obsrvd_alloc_evct_way = -1;
        end 
        if (tag_sf.obsrvd_vctb_hit || tag_sf.obsrvd_tagf_hit) begin
            tag_sf.obsrvd_hit_swap_way = get_waynum(sfid, lkprsp.m_way_vec_or_mask);
            `uvm_info("DIRM MGR", $psprintf("dm_lkprsp_sf_coverage --> sfid:%0d tag_hit:%0b vctb_hit:%0b hit_way:%0d", sfid, tag_sf.obsrvd_tagf_hit, tag_sf.obsrvd_vctb_hit, get_waynum(sfid, lkprsp.m_way_vec_or_mask)), UVM_MEDIUM)
        end else begin 
            tag_sf.obsrvd_hit_swap_way = -1;
        end 
    end//loop sf
endfunction: dm_lkprsp_sf_coverage

//This function is called only on rtyrsp
function void directory_mgr::collect_dm_rtyrsp_coverage();
    bit en_samp[string];
    tag_snoop_filter tag_sf;
    m_sampleq = {};

    for(int m_sfid = 0; m_sfid < ncoreConfigInfo::NUM_SF; m_sfid++) begin
        if((ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") && is_snoop_filter_en(m_sfid)) begin
            en_samp["home_filter"]               = 1'b0;
            en_samp["all_ways_busy"]             = 1'b0;
            en_samp["vctb_hit"]                  = 1'b0;
            en_samp["alloc_miss"]                = 1'b0;

            m_sampleq.push_back(en_samp);
        end
    end

    for(int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        if((ncoreConfigInfo::snoop_filters_info[sfid].filter_type == "TAGFILTER") && is_snoop_filter_en(sfid)) begin

            tag_sf = get_tag_sf_handle(sfid);
            
            if(tag_sf.obsrvd_vctb_hit) begin
                m_sampleq[sfid]["vctb_hit"] = 1'b1;
                tag_sf.obsrvd_vctb_hit = 1'b0;
            end
            if(tag_sf.obsrvd_tagf_hit) begin
                m_sampleq[sfid]["tagf_hit"] = 1'b1;
                tag_sf.obsrvd_tagf_hit = 1'b0;
            end

            if(tag_sf.obsrvd_alloc_miss) begin
                m_sampleq[sfid]["alloc_miss"] = 1'b1;
                tag_sf.obsrvd_alloc_miss = 1'b0;
            end
            
            if(tag_sf.obsrvd_home_filter) begin
                m_sampleq[sfid]["home_filter"] = 1'b1;
                tag_sf.obsrvd_home_filter = 1'b0;
            end
            
            if(tag_sf.obsrvd_all_ways_busy) begin
                m_sampleq[sfid]["all_ways_busy"] = 1'b1;
                tag_sf.obsrvd_all_ways_busy = 1'b0;
            end
        end
    end
endfunction: collect_dm_rtyrsp_coverage

//This function is called at: 
//lkprsp
//updreq
//recreq
function void directory_mgr::collect_dm_coverage();

    bit en_samp[string];
    int vctb_cnt;
    tag_snoop_filter tag_sf;

    int vctb_hit_cnt, tagf_hit_cnt, miss_cnt;

    //Reset
    m_sampleq = {};
    m_alloc_evct_wayq = {};
    m_hit_swap_wayq = {};
    obsrvd_vctb_hit_in_multiple_sf = 1'b0;
    obsrvd_vctb_hit_in_all_sf      = 1'b0;
    obsrvd_tagf_hit_in_multiple_sf = 1'b0;
    obsrvd_tagf_hit_in_all_sf      = 1'b0;
    obsrvd_vctb_hit_tagf_hit       = 1'b0;

    for(int m_sfid = 0; m_sfid < ncoreConfigInfo::NUM_SF; m_sfid++) begin
        if((ncoreConfigInfo::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") && is_snoop_filter_en(m_sfid)) begin
            en_samp["tagf_hit"]                  = 1'b0;
            en_samp["vctb_hit"]                  = 1'b0;
            en_samp["alloc_miss"]                = 1'b0;
            en_samp["updreq_hit_owner_updcomp"]  = 1'b0;
            en_samp["updreq_hit_sharer_updcomp"] = 1'b0;
            en_samp["updreq_miss_updfail"]       = 1'b0;
            en_samp["updreq_hit_updfail"]        = 1'b0;
            en_samp["recreq"]                    = 1'b0;

            m_sampleq.push_back(en_samp);

            m_alloc_evct_wayq.push_back(-1);
            m_hit_swap_wayq.push_back(-1);
        end
    end

    vctb_hit_cnt  = 0;  //Address hit in Victim Buffer count
    tagf_hit_cnt  = 0;  //Address hit in Tag filter count
    miss_cnt      = 0;  //Address miss 
    for(int sfid = 0; sfid < ncoreConfigInfo::NUM_SF; sfid++) begin
        if((ncoreConfigInfo::snoop_filters_info[sfid].filter_type == "TAGFILTER") && is_snoop_filter_en(sfid)) begin

            tag_sf = get_tag_sf_handle(sfid);
            if (tag_sf.get_vctb_depth() > 0) begin
                vctb_cnt++;
            end

            if(tag_sf.obsrvd_tagf_hit) begin
                m_sampleq[sfid]["tagf_hit"] = 1'b1;
                tagf_hit_cnt++;
                tag_sf.obsrvd_tagf_hit = 1'b0;
            end
            
            if(tag_sf.obsrvd_vctb_hit) begin
                m_sampleq[sfid]["vctb_hit"] = 1'b1;
                vctb_hit_cnt++;
                tag_sf.obsrvd_vctb_hit = 1'b0;
            end

            if(tag_sf.obsrvd_alloc_miss) begin
                m_sampleq[sfid]["alloc_miss"] = 1'b1;
        miss_cnt++;
                tag_sf.obsrvd_alloc_miss = 1'b0;
            end
            
            if(tag_sf.obsrvd_home_filter) begin
                m_sampleq[sfid]["home_filter"] = 1'b1;
                tag_sf.obsrvd_home_filter = 1'b0;
            end
            
            if(tag_sf.obsrvd_all_ways_busy) begin
                m_sampleq[sfid]["all_ways_busy"] = 1'b1;
                tag_sf.obsrvd_all_ways_busy = 1'b0;
            end
            
            if(tag_sf.obsrvd_updreq_hit_as_owner_upd_comp) begin
                m_sampleq[sfid]["updreq_hit_owner_updcomp"] = 1'b1;
                tag_sf.obsrvd_updreq_hit_as_owner_upd_comp = 1'b0;
            end
            
            if(tag_sf.obsrvd_updreq_hit_as_sharer_upd_comp) begin
                m_sampleq[sfid]["updreq_hit_sharer_updcomp"] = 1'b1;
                tag_sf.obsrvd_updreq_hit_as_sharer_upd_comp = 1'b0;
            end
            
            if(tag_sf.obsrvd_updreq_miss_upd_fail) begin
                m_sampleq[sfid]["updreq_miss_updfail"] = 1'b1;
                tag_sf.obsrvd_updreq_miss_upd_fail = 1'b0;
            end
            
            if(tag_sf.obsrvd_updreq_hit_upd_fail) begin
                m_sampleq[sfid]["updreq_hit_updfail"] = 1'b1;
                tag_sf.obsrvd_updreq_hit_upd_fail = 1'b0;
            end
            
            if(tag_sf.obsrvd_recreq) begin
                m_sampleq[sfid]["recreq"] = 1'b1;
                tag_sf.obsrvd_recreq = 1'b0;
            end
            
            m_alloc_evct_wayq[sfid] = tag_sf.obsrvd_alloc_evct_way;
            m_hit_swap_wayq[sfid]   = tag_sf.obsrvd_hit_swap_way;
        end
    end
        
    if(vctb_hit_cnt == vctb_cnt) begin
        obsrvd_vctb_hit_in_all_sf = 1'b1;
        `uvm_info("DM COV", "vctb_hit on all SF", UVM_MEDIUM)
    end

    if((vctb_hit_cnt > 0) && (tagf_hit_cnt > 0)) begin
        obsrvd_vctb_hit_tagf_hit = 1'b1;
        `uvm_info("DM COV", "vctb_hit and tagf_hit in one or more SF cacheline:0x%h", UVM_MEDIUM)
    end
    
    if(vctb_hit_cnt > 1)
        obsrvd_vctb_hit_in_multiple_sf = 1'b1;
    
    if(tagf_hit_cnt > 1)
        obsrvd_tagf_hit_in_multiple_sf = 1'b1;
    
    if((miss_cnt > 0) && (vctb_hit_cnt > 0))
    obsrvd_alloc_miss_vb_hit = 1'b1;

endfunction: collect_dm_coverage

function void directory_mgr::log_cov_hit (string msg, int filter_id);

    if(m_dirm_dbg) begin
        `uvm_info("DIRM MGR", $psprintf("COV: %s:%b sfid:%0d",
            msg, 1'b1, filter_id), UVM_MEDIUM)
    end
endfunction: log_cov_hit

function int directory_mgr::get_waynum (int sfid_i, bit [WSFWAYVEC-1:0] way_vec_i);

    bit [WSFWAYVEC-1:0] mask;
    tag_snoop_filter    tag_sf, req_tag_sf;  
    int                 startBit = 0;
    int                 way_num = 0;
    int                 isolatedXbits;

    req_tag_sf  = get_tag_sf_handle(sfid_i);
    for (int sidx = 0; sidx < ncoreConfigInfo::NUM_SF; sidx++) begin
        tag_sf = get_tag_sf_handle(sidx);
        if (sidx == sfid_i) begin
            mask = ((1 << tag_sf.num_ways) - 1) << startBit;
            isolatedXbits = (way_vec_i & mask) >> startBit;
            if (isolatedXbits == 0) begin
                return -1;
            //#Check.DCE.dm_CmdRspWayVecOneHotOrZeroAnyReq  
            end else if ($countones(isolatedXbits) > 1) begin
                    `uvm_error("DIRM MGR", $psprintf("fn:get_waynum More than one way is asserted in dm_lkp_rsp for sfid:%0d way_vec:0x%0h", sfid_i, way_vec_i))
            end
            way_num = 0;

            while (isolatedXbits != 0) begin
                if ((isolatedXbits & 'h1) == 1) begin
                    break;          
                end else begin
                    isolatedXbits = isolatedXbits >> 1;
                    way_num++;
                end
            end
            break;
        end
        startBit = startBit + tag_sf.num_ways;
    end
    
    //#Check.DCE.dm_CmdRspWayNumLegal
    if (way_num >= req_tag_sf.num_ways)
        `uvm_error("DIRM MGR", $psprintf("fn:get_waynum way_num(%0d) is greater or equal to num_ways(%0d) for sfid(%0d))", way_num, tag_sf.num_ways, sfid_i))
    return way_num;

endfunction:get_waynum
