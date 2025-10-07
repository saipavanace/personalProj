typedef bit [(($size(<%=obj.BlockId + '_con'%>::aceState_t)*<%=obj.BlockId + '_con'%>::SYS_nSysAIUs)*2)-1:0] aceStatesPairInBits_t;

////////////////////////////////////////////////////////////////////////////////
//
// ACE State Transition - all data items needed to make ace state transition
//
////////////////////////////////////////////////////////////////////////////////

class AceStateTransition;

  <%=obj.BlockId + '_con'%>::AIUID_t        req_aiu_id;
  <%=obj.BlockId + '_con'%>::aceState_t     initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
  <%=obj.BlockId + '_con'%>::eMsgACE        cmd_req_msg;
  <%=obj.BlockId + '_con'%>::eMsgACE        snp_req_msgs  [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
  <%=obj.BlockId + '_con'%>::aceSnoopResult_t  snoop_results [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
  <%=obj.BlockId + '_con'%>::aceSnoopResult_t  coher_result;
  <%=obj.BlockId + '_con'%>::aceState_t     ending_state  [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

endclass : AceStateTransition

////////////////////////////////////////////////////////////////////////////////
//
// Ace State Test Generator
//
////////////////////////////////////////////////////////////////////////////////

class AceStateTestGen;

  int MAX_GRAPH_DEPTH = (<%=obj.BlockId + '_con'%>::SYS_nSysAIUs >= 5) ? 116 : 50;

  typedef aceStatesPairInBits_t  T;
  typedef T            graph_map_t  [T][$];
  typedef T            graph_list_t [];
  typedef graph_list_t graph_lists_t [$];

  typedef bit [15:0] count_t;

  typedef struct packed {
    count_t count;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  aceStatesInBits;
  } count_aceStatesInBits_t;

  localparam count_t COUNT_LIMIT = 32;

  <%=obj.BlockId + '_con'%>::aceStatesInBits_t  aceStateTransitionList [$];
  bit                   scb [aceStatesPairInBits_t];
  bit                   scb1 [<%=obj.BlockId + '_con'%>::aceStatesInBits_t];

  <%=obj.BlockId + '_con'%>::aceStatesInBits_t  aceStateTransitionMap0 [<%=obj.BlockId + '_con'%>::aceStatesInBits_t] [$];
  <%=obj.BlockId + '_con'%>::aceStatesInBits_t  aceStateTransitionMapR [<%=obj.BlockId + '_con'%>::aceStatesInBits_t] [$];
  AceStateTransition aceStateTransitionMap1 [<%=obj.BlockId + '_con'%>::aceStatesInBits_t] [$];
  AceStateTransition aceStateTransitionMap2 [aceStatesPairInBits_t] [$];
  graph_map_t          graph;
  <%=obj.BlockId + '_con'%>::aceState_t    statesList [$] [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

  int                  unique_test_cases;
  int                  unique_state_transitions;

  //////////////////////////////////////////////////////////////////////////////
  // function __find_path
  //////////////////////////////////////////////////////////////////////////////
  function graph_list_t __find_path(graph_map_t graph, T startp, T endp, graph_list_t path = {});

    automatic graph_list_t empty_path;
    automatic graph_list_t new_path;
    automatic T            node;
    automatic int          qx [$];
    path = {path, startp};
    if (path.size() > MAX_GRAPH_DEPTH)
      return path;
    if (startp == endp)
      return path;
    if (!graph.exists(startp))
      return empty_path;
    foreach (graph[startp][i]) begin
      node = graph[startp][i];
      //Boon: Cadence Incisive simulator complains about this line that contains the "inside" keyword
      //
      //if (!(node inside path)) begin
      //
      qx = path.find_first_index() with (item == node);
      if (qx.size() == 0) begin
        new_path = __find_path(graph, node, endp, path);
        if (new_path.size()) return new_path;
      end
    end
    return empty_path;

  endfunction : __find_path

  //////////////////////////////////////////////////////////////////////////////
  // function __buildTest
  //////////////////////////////////////////////////////////////////////////////
  function void __buildTest (<%=obj.BlockId + '_con'%>::AIUID_t req_aiu_id, <%=obj.BlockId + '_con'%>::aceState_t initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs]);

    <%=obj.BlockId + '_con'%>::eMsgACE        cmd_req_msgs [];
    <%=obj.BlockId + '_con'%>::eMsgACE        snp_req_msgs [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

    <%=obj.BlockId + '_con'%>::aceSnoopResult_t  snoop_results [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs][$];
    <%=obj.BlockId + '_con'%>::aceSnoopResult_t  snoop_comb_results [][<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

    <%=obj.BlockId + '_con'%>::aceState_t   snoop_ending_states [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs][$];
    <%=obj.BlockId + '_con'%>::aceState_t   snoop_comb_states [][<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

    <%=obj.BlockId + '_con'%>::aceSnoopResult_t  coher_results [];

    <%=obj.BlockId + '_con'%>::aceState_t     trans_ending_states [$];
    <%=obj.BlockId + '_con'%>::aceState_t     ending_states [][<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;

    AceStateTransition aceStateTransition;

    //
    // Generate a list of CMDreq messages based on the Requesting AIU Cacheline State
    //
    <%=obj.BlockId + '_con'%>::convertAceStatesToBits (initial_state, initial_state_in_bits);

    <%=obj.BlockId + '_con'%>::genAceCMDreqs (initial_state[req_aiu_id], cmd_req_msgs);

    for (int m=0; m < cmd_req_msgs.size(); m++) begin

      //
      // Generate Snoop Results based on the selected CMDreq message
      //
      for (int c = 0; c < <%=obj.BlockId + '_con'%>::SYS_nSysAIUs; c++) begin
        if ( c != req_aiu_id ) begin
          if (<%=obj.BlockId + '_con'%>::mapAceOwnerSNPreq(cmd_req_msgs[m], snp_req_msgs[c])) begin
            <%=obj.BlockId + '_con'%>::genAceSnoopResults (initial_state[c], snp_req_msgs[c], snoop_results[c], snoop_ending_states[c]); 
          end
        end else begin
          snoop_results[c].delete();
          snoop_ending_states[c].delete();
        end
      end

      //
      // Generate all permutations of the Snooping AIUs' ending states
      //
      <%=obj.BlockId + '_con'%>::genCombAceStates(snoop_ending_states, snoop_comb_states);

      for (int i=0; i < snoop_comb_states.size(); i++) begin
        snoop_comb_states[i][req_aiu_id] = initial_state[req_aiu_id]; 
      end

      //
      // Generate all permutations of the Snooping Results
      //
      <%=obj.BlockId + '_con'%>::genCombAceSnoopResults(snoop_results, snoop_comb_results);

      //
      // Generate the Coherence Result from the Snooping Results
      //

      <%=obj.BlockId + '_con'%>::genAceCoherResultsFromSnoops(snoop_comb_results, coher_results);

      for (int k=0; k < coher_results.size(); k++) begin

        //
        // Generate the Transaction Result from the Coherence Result
        //
        <%=obj.BlockId + '_con'%>::genAceCommandResults(cmd_req_msgs[m], coher_results[k], trans_ending_states, initial_state[req_aiu_id]);

        //
        // Generate the ending states for all AIUs
        //
        <%=obj.BlockId + '_con'%>::genAceStatesFromReqAIUEndingStates(snoop_comb_states[k], req_aiu_id, trans_ending_states, ending_states);

        for (int s=0; s < ending_states.size(); s++) begin

if (<%=obj.BlockId + '_con'%>::isLegalAceCommandStateTransition (cmd_req_msgs[m], coher_results[k].IS, coher_results[k].PD, initial_state[req_aiu_id], ending_states[s][req_aiu_id])) begin

          aceStateTransition = new();

          aceStateTransition.req_aiu_id    = req_aiu_id;
          aceStateTransition.initial_state = initial_state;
          aceStateTransition.cmd_req_msg   = cmd_req_msgs[m];
          aceStateTransition.snp_req_msgs  = snp_req_msgs;
          aceStateTransition.snoop_results = snoop_comb_results[k];
          aceStateTransition.coher_result  = coher_results[k];
          aceStateTransition.ending_state  = ending_states[s];

          <%=obj.BlockId + '_con'%>::convertAceStatesToBits (ending_states[s], ending_state_in_bits);
          aceStateTransitionMap0 [initial_state_in_bits].push_back(ending_state_in_bits);
          aceStateTransitionMap1 [initial_state_in_bits].push_back(aceStateTransition);
          aceStateTransitionMap2 [{initial_state_in_bits, ending_state_in_bits}].push_back(aceStateTransition);

          unique_test_cases++;

end //if

        end // for s

      end // for k

    end // for m

  endfunction : __buildTest

  //////////////////////////////////////////////////////////////////////////////
  // function buildTest
  //////////////////////////////////////////////////////////////////////////////
  function void buildTest();

    <%=obj.BlockId + '_con'%>::AIUID_t            req_aiu_id;
    <%=obj.BlockId + '_con'%>::aceState_t         initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;

    unique_test_cases = 0;
    unique_state_transitions = 0;

    //
    // Build a list of legal states
    //
    <%=obj.BlockId + '_con'%>::genLegalAceStates (statesList);

    //
    // Build an exhaustive list of test cases
    //
    for (int i=0; i < statesList.size(); i++) begin

      initial_state = statesList[i];

      for (int j=0; j < <%=obj.BlockId + '_con'%>::SYS_nSysAIUs; j++) begin

        req_aiu_id = j;

        __buildTest (req_aiu_id, initial_state);

      end // for j < <%=obj.BlockId + '_con'%>::SYS_nSysAIUs

    end // for i < statesList.size()

    //
    // Build a graph
    //
    foreach (aceStateTransitionMap2[index]) begin

      {initial_state_in_bits, ending_state_in_bits} = index;

      graph[initial_state_in_bits].push_back(ending_state_in_bits);

      unique_state_transitions++;

    end

  endfunction : buildTest

  //////////////////////////////////////////////////////////////////////////////
  // searchGraph
  //////////////////////////////////////////////////////////////////////////////
  function void searchGraph(<%=obj.BlockId + '_con'%>::aceState_t  initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs],
                            <%=obj.BlockId + '_con'%>::aceState_t  ending_state  [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs],
                     output <%=obj.BlockId + '_con'%>::aceState_t  result_states [$] [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs]);

    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceState_t    state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    graph_list_t         paths;

    <%=obj.BlockId + '_con'%>::convertAceStatesToBits (initial_state, initial_state_in_bits);
    <%=obj.BlockId + '_con'%>::convertAceStatesToBits (ending_state,  ending_state_in_bits);
    paths = __find_path(graph, initial_state_in_bits, ending_state_in_bits);

    foreach (paths[index]) begin
      <%=obj.BlockId + '_con'%>::convertAceBitsToStates (paths[index], state);
      result_states.push_back(state);
    end

  endfunction : searchGraph

  //////////////////////////////////////////////////////////////////////////////
  // printGraph
  //////////////////////////////////////////////////////////////////////////////
  function void printGraph();
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  mapf[<%=obj.BlockId + '_con'%>::aceStatesInBits_t] [$];
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  mapr[<%=obj.BlockId + '_con'%>::aceStatesInBits_t] [$];
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceState_t         initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    <%=obj.BlockId + '_con'%>::aceState_t         ending_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

    $display("BEGIN of printGraph");

    $display("Legal states are:");
    foreach (statesList[i]) begin
      $display("%p", statesList[i]);
    end
    $display("The number of legal states is %0d", statesList.size());

    foreach (aceStateTransitionMap2[index]) begin
      {initial_state_in_bits, ending_state_in_bits} = index;
      <%=obj.BlockId + '_con'%>::convertAceBitsToStates (initial_state_in_bits, initial_state);
      <%=obj.BlockId + '_con'%>::convertAceBitsToStates (ending_state_in_bits, ending_state);
      $display("%p -> %p", initial_state, ending_state);
    end

    foreach (aceStateTransitionMap2[index]) begin
      {initial_state_in_bits, ending_state_in_bits} = index;
      mapr[ending_state_in_bits].push_back(initial_state_in_bits);
      mapf[initial_state_in_bits].push_back(ending_state_in_bits);
    end

    foreach (mapf[initial_state_in_bits]) begin
      <%=obj.BlockId + '_con'%>::convertAceBitsToStates (initial_state_in_bits, initial_state);
      $display("%p has %0d outgoing states", initial_state, mapf[initial_state_in_bits].size());
      for (int i=0; i < mapf[initial_state_in_bits].size(); i++) begin
        ending_state_in_bits = mapf[initial_state_in_bits][i];
        <%=obj.BlockId + '_con'%>::convertAceBitsToStates (ending_state_in_bits, ending_state);
        $display("%p -> %p", initial_state, ending_state);
      end
    end

    foreach (mapr[ending_state_in_bits]) begin
      <%=obj.BlockId + '_con'%>::convertAceBitsToStates (ending_state_in_bits, ending_state);
      $display("%p has %0d incoming states", ending_state, mapr[ending_state_in_bits].size());
      for (int i=0; i < mapr[ending_state_in_bits].size(); i++) begin
        initial_state_in_bits = mapr[ending_state_in_bits][i];
        <%=obj.BlockId + '_con'%>::convertAceBitsToStates (initial_state_in_bits, initial_state);
        $display("%p <- %p", ending_state, initial_state);
      end
    end

    $display("END of printGraph");

  endfunction : printGraph

  //////////////////////////////////////////////////////////////////////////////
  // buildList
  //////////////////////////////////////////////////////////////////////////////
  function void __buildList(
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  state_in_bits
  );

    count_aceStatesInBits_t  map [<%=obj.BlockId + '_con'%>::aceStatesInBits_t] [$];
    count_t count;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;
    aceStatesPairInBits_t index;
    int max_c, max_i;

    foreach (aceStateTransitionMap2[index]) begin
      {initial_state_in_bits, ending_state_in_bits} = index;
      map[initial_state_in_bits].push_back({COUNT_LIMIT, ending_state_in_bits});
    end

    max_i = 0;
    max_c = 0;
    initial_state_in_bits = state_in_bits;
    map[initial_state_in_bits].shuffle();
    {count, ending_state_in_bits} = map[initial_state_in_bits][max_i];

    while (count) begin
      count--;
      map[initial_state_in_bits][max_i] = {count, ending_state_in_bits};

      aceStateTransitionList.push_back(initial_state_in_bits);
      aceStateTransitionList.push_back(ending_state_in_bits);
      index = {initial_state_in_bits, ending_state_in_bits};
      scb[index] = 1;
      scb1[initial_state_in_bits] = 1;
      scb1[ending_state_in_bits] = 1;

      initial_state_in_bits = ending_state_in_bits;
      map[initial_state_in_bits].shuffle();
      max_c = 0;
      max_i = 0;
      for (int i=0; i < map[initial_state_in_bits].size(); i++) begin
        {count, ending_state_in_bits} = map[initial_state_in_bits][i];
        if (count > max_c) begin
          max_c = count;
          max_i = i;
        end
        index = {initial_state_in_bits, ending_state_in_bits};
        if (scb[index] == 0) begin
          max_i = i;
          break;
        end
      end //for
      {count, ending_state_in_bits} = map[initial_state_in_bits][max_i];
    end //while

    aceStateTransitionList.push_back(initial_state_in_bits);
    aceStateTransitionList.push_back(ending_state_in_bits);
    index = {initial_state_in_bits, ending_state_in_bits};
    scb[index] = 1;
    scb1[initial_state_in_bits] = 1;
    scb1[ending_state_in_bits] = 1;

  endfunction : __buildList

  function void buildList(<%=obj.BlockId + '_con'%>::aceStatesInBits_t  start_state_in_bits = 0);

    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;

    aceStateTransitionList.delete();
    foreach (aceStateTransitionMap2[index]) begin
      {initial_state_in_bits, ending_state_in_bits} = index;
      scb [index] = 0;
      scb1[initial_state_in_bits] = 0;
      scb1[ending_state_in_bits] = 0;
    end
    initial_state_in_bits = start_state_in_bits;
    __buildList(initial_state_in_bits);
  //for (int iter = 0; iter < 1; iter++) begin
  //  __buildList(aceStateTransitionList[aceStateTransitionList.size()-1]);
  //end

  endfunction : buildList

  //////////////////////////////////////////////////////////////////////////////
  // printList
  //////////////////////////////////////////////////////////////////////////////
  function void printList();
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceState_t         initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    <%=obj.BlockId + '_con'%>::aceState_t         ending_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    AceStateTransition           stimulusList [$];
    AceStateTransition           stimulus;

    $display("BEGIN of printList");
    for (int i=0; i < aceStateTransitionList.size()-2; i=i+1) begin
      initial_state_in_bits = aceStateTransitionList[i];
      ending_state_in_bits = aceStateTransitionList[i+1];
      <%=obj.BlockId + '_con'%>::convertAceBitsToStates (initial_state_in_bits, initial_state);
      <%=obj.BlockId + '_con'%>::convertAceBitsToStates (ending_state_in_bits, ending_state);
      $display("%0d : %p -> %p", i, initial_state, ending_state);
`ifdef ACE_GRAPH_TEST_BRINGUP
      stimulusList = aceStateTransitionMap2 [{initial_state_in_bits, ending_state_in_bits}];
      for (int k=0; k < stimulusList.size()-1; k++) begin
        $display("req_aiu_id=%x initial_state=%p -> end_state=%p cmd=%p snp=%p snpres=%p coher=%p",
          stimulusList[k].req_aiu_id,
          stimulusList[k].initial_state,
          stimulusList[k].ending_state,
          stimulusList[k].cmd_req_msg,
          stimulusList[k].snp_req_msgs,
          stimulusList[k].snoop_results,
          stimulusList[k].coher_result);
      end
`endif
    end
    $display("END of printList");

  endfunction : printList

  //////////////////////////////////////////////////////////////////////////////
  // printMissList
  //////////////////////////////////////////////////////////////////////////////
  function void printMissList();
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceState_t         initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    <%=obj.BlockId + '_con'%>::aceState_t         ending_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    int num_miss;
    int num_hit;
    aceStatesPairInBits_t index;

    $display("BEGIN of printMissList");
    num_miss = 0;
    num_hit = 0;
    foreach (scb[index]) begin
      if (scb[index] == 0) begin
        num_miss++;
        {initial_state_in_bits, ending_state_in_bits} = index;
        <%=obj.BlockId + '_con'%>::convertAceBitsToStates (initial_state_in_bits, initial_state);
        <%=obj.BlockId + '_con'%>::convertAceBitsToStates (ending_state_in_bits, ending_state);
        $display("%p -> %p", initial_state, ending_state);
      end
      if (scb[index] == 1) begin
        num_hit++;
      end
    end
    $display("buildList has %d misses (as shown above), %d hits (not shown above)", num_miss, num_hit);
    $display("END of printMissList");

  endfunction : printMissList

  //////////////////////////////////////////////////////////////////////////////
  // printMissState
  //////////////////////////////////////////////////////////////////////////////
  function void printMissState();
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  initial_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceStatesInBits_t  ending_state_in_bits;
    <%=obj.BlockId + '_con'%>::aceState_t         initial_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];
    <%=obj.BlockId + '_con'%>::aceState_t         ending_state [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs];

    $display("BEGIN of printMissState");
    foreach (scb1[state_in_bits]) begin
      if (scb1[state_in_bits] == 0) begin
        <%=obj.BlockId + '_con'%>::convertAceBitsToStates (state_in_bits, initial_state);
        $display("%p", initial_state);
      end
    end
    $display("END of printMissState");

  endfunction : printMissState

endclass : AceStateTestGen

