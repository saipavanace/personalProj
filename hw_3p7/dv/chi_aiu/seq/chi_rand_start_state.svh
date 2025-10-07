

class chi_rand_start_state extends uvm_object;

  `uvm_object_param_utils(chi_rand_start_state)

  chi_bfm_opcode_t           m_opcode;
  chi_bfm_opcode_type_t      m_opcode_type;
  rand chi_bfm_cache_state_t m_start_state;
  rand bit                   m_snoopme;
  bit		             force_start_state_ix;

  constraint c_start_state {
    if (m_opcode_type == RD_RDONCE_CMD) {
      if(force_start_state_ix){
	m_start_state == CHI_IX;
      }else{
        m_start_state inside {CHI_IX, CHI_UCE };
      }

    } else if (m_opcode_type == RD_LDRSTR_CMD) {
      if(force_start_state_ix){
	m_start_state == CHI_IX;
      }else{
	(m_opcode inside {BFM_READSHARED, BFM_READCLEAN}) -> m_start_state inside{CHI_IX, CHI_UCE};
      	(m_opcode inside {BFM_READUNIQUE}) -> m_start_state inside{CHI_IX, CHI_SC, CHI_SD};
      }
    } else if (m_opcode_type == DT_LS_UPD_CMD) {
      (m_opcode  == BFM_EVICT) -> m_start_state  == CHI_UC;
      if(force_start_state_ix && (m_opcode == BFM_CLEANUNIQUE || m_opcode == BFM_MAKEUNIQUE)){
	m_start_state == CHI_IX;
      }else{
      	(m_opcode == BFM_CLEANUNIQUE || m_opcode == BFM_MAKEUNIQUE) ->
        	m_start_state inside {CHI_IX, CHI_SC, CHI_SD};
	}

    } else if (m_opcode_type == DT_LS_CMO_CMD) {
      if(force_start_state_ix){
	m_start_state == CHI_IX;
      }else{
      	(m_opcode == BFM_CLEANSHARED || m_opcode == BFM_CLEANSHAREDPERSIST) ->
         	m_start_state inside {CHI_IX, CHI_SC};
      }
      (m_opcode == BFM_CLEANINVALID || m_opcode == BFM_MAKEINVALID) ->
         m_start_state == CHI_IX;

    } else if (m_opcode_type == WR_COHUNQ_CMD) {
         (m_opcode inside {BFM_WRITEUNIQUEFULL,BFM_WRITEUNIQUEPTL}) -> 
         m_start_state inside
           {CHI_IX};

    } else if (m_opcode_type == WR_CPYBCK_CMD) {
      (m_opcode == BFM_WRITEBACKFULL || m_opcode == BFM_WRITECLEANFULL) ->
         m_start_state inside {CHI_UD, CHI_SD, CHI_SC};
      if(force_start_state_ix && (m_opcode == BFM_WRITEBACKPTL  || m_opcode == BFM_WRITECLEANPTL)){
	m_start_state == CHI_IX;
      }else{
      	(m_opcode == BFM_WRITEBACKPTL  || m_opcode == BFM_WRITECLEANPTL)  ->
         	m_start_state inside {CHI_UDP};
      }
      (m_opcode == BFM_WRITEEVICTFULL) -> m_start_state == CHI_UC;

    } else if (m_opcode_type == ATOMIC_ST_CMD || 
               m_opcode_type == ATOMIC_LD_CMD ||
               m_opcode_type == ATOMIC_SW_CMD ||
               m_opcode_type == ATOMIC_CM_CMD)   {
      	if(force_start_state_ix){
		m_start_state == CHI_IX;
      	}else{
        	m_start_state dist {
          	CHI_IX  := 40,
          	CHI_SC  := 10,
          	CHI_SD  := 10,
          	CHI_UC  := 10,
          	CHI_UCE := 10,
          	CHI_UD  := 10,
          	CHI_UDP := 10
        	};
	}
    } else {
      m_start_state == CHI_IX;
      //Need to add support for below senarios
      //(m_opcode_type == PRE_FETCH_CMD) -> 
    }
  }

  constraint c_snoop_me {
    if ((m_opcode_type == ATOMIC_ST_CMD || m_opcode_type == ATOMIC_LD_CMD ||
         m_opcode_type == ATOMIC_SW_CMD || m_opcode_type == ATOMIC_CM_CMD)  &&
        (m_start_state != CHI_IX))
      m_snoopme == 1;
    else
      m_snoopme == 0;
  }

  function new(string s = "chi_rand_start_state");
    super.new(s);
  endfunction: new

  function chi_bfm_cache_state_t pick_rand_start_state(
    chi_bfm_opcode_t      opcode,
    chi_bfm_opcode_type_t opcode_type,
    bit			  start_ix=0);

    m_opcode = opcode;
    m_opcode_type = opcode_type;
    force_start_state_ix = start_ix;
    `ASSERT(randomize());
    return m_start_state;
  endfunction:pick_rand_start_state

  function bit pick_snoopme();
    return m_snoopme;
  endfunction: pick_snoopme

endclass: chi_rand_start_state
