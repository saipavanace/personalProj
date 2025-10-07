class chi_tx_dat_chnl_cb#(int ID = 0) extends uvm_object;

  `uvm_object_param_utils(chi_tx_dat_chnl_cb#(ID))

  //Properties
  chi_aiu_unit_args m_args;
  chi_bfm_dat_t m_txn[$];
<%if(obj.testBench != "fsys"){ %>
  chi_bfm_dat_t m_txn_interleave[][$];
  int           pend_txn;
  int           push_q_idx;
  int           pop_q_idx;
  int           MAX_INTERLEAVE;
<%}%>

  function new(string s = "chi_tx_dat_chnl_cb");
    super.new(s);
<%if(obj.testBench != "fsys"){ %>
    pend_txn = 0;
    push_q_idx = 0;
    pop_q_idx = 0;
    if(!$value$plusargs("max_interleave=%d", MAX_INTERLEAVE)) begin
      MAX_INTERLEAVE = $urandom_range(8, 1);
    end
    $display("INFO:: MAX_INTERLEAVE: %0d", MAX_INTERLEAVE);
    m_txn_interleave = new[MAX_INTERLEAVE];
<%}%>
  endfunction: new

  function void set_chi_unit_args(const ref chi_aiu_unit_args args);
    m_args = args;
  endfunction: set_chi_unit_args 

  virtual function void put_chi_txn(chi_bfm_dat_t txn);
    m_txn.push_back(txn);
  endfunction: put_chi_txn

<%if(obj.testBench == "fsys" || obj.testBench == "emu"){ %>
  virtual task get_chi_txn(output chi_bfm_dat_t txn);
    wait (m_txn.size() > 0);
    m_txn.shuffle();
    txn = m_txn.pop_front();
  endtask: get_chi_txn
<%} else { %>
  virtual function bit check_queues_not_empty();
    bit not_empty = 0;
    foreach(m_txn_interleave[i]) begin
      if (m_txn_interleave[i].size() > 0) begin
         not_empty = 1;
         break;
      end
    end
    return not_empty;
  endfunction: check_queues_not_empty

  virtual function bit check_queues_all_empty();
    bit is_empty = 1;
    foreach(m_txn_interleave[i]) begin
      if (m_txn_interleave[i].size() != 0) begin
         is_empty = 0;
         break;
      end
    end
    return is_empty;
  endfunction: check_queues_all_empty

  virtual function int get_next_pop_idx(int curr_idx);
    int next_idx;
    foreach(m_txn_interleave[i]) begin
      if (m_txn_interleave[curr_idx+i+1].size() != 0) begin
         next_idx = (curr_idx+i+1) % MAX_INTERLEAVE;
         break;
      end
    end
    return next_idx;
  endfunction: get_next_pop_idx

  virtual task get_chi_txn(output chi_bfm_dat_t txn, const ref int txn_id_pool[$]);
    chi_bfm_dat_t temp_txn, cpy_txn;
    //wait ((m_txn.size() > 0) || check_queues_not_empty());
    while ((pend_txn < MAX_INTERLEAVE) && ((256 - txn_id_pool.size()) >= MAX_INTERLEAVE || pend_txn == 0) && ((pend_txn == 0) || (m_txn.size == 0) || (256 - txn_id_pool.size()) >= MAX_INTERLEAVE)) begin
      wait ((m_txn.size() > 0) || (((256 - txn_id_pool.size()) < MAX_INTERLEAVE) && (pend_txn != 0)));
      if ((m_txn.size() != 0) && (m_txn_interleave[push_q_idx].size == 0)) begin
        m_txn.shuffle();
        temp_txn = m_txn.pop_front();
        pend_txn++;
        cpy_txn = temp_txn;
        for (int i = 0; i < temp_txn.m_info.num_flits(); ++i) begin
          cpy_txn.m_info = new(temp_txn.m_info.get_bytes_pflit());
          cpy_txn.m_info.set_txdat_info(
              temp_txn.m_info.get_ccid,
              1,
              temp_txn.m_info.m_data,
              temp_txn.m_info.m_be,
              temp_txn.m_info.get_tx_dataid(i)
          );
          m_txn_interleave[push_q_idx].push_back(cpy_txn);
        end
        push_q_idx = (push_q_idx + 1) % MAX_INTERLEAVE;
      end
    end

    if ((pend_txn >= MAX_INTERLEAVE) || check_queues_not_empty()) begin
      if (m_txn_interleave[pop_q_idx].size != 0) begin
        txn = m_txn_interleave[pop_q_idx].pop_front();
      end
      else begin
        foreach(m_txn_interleave[i]) begin
          pop_q_idx = get_next_pop_idx(pop_q_idx);
          txn = m_txn_interleave[pop_q_idx].pop_front();
          break;
        end
      end
      pop_q_idx = get_next_pop_idx(pop_q_idx);
      if (check_queues_all_empty()) begin
        pend_txn = pend_txn - MAX_INTERLEAVE;
        if (pend_txn < 0) begin
          pend_txn = 0;
        end
      end
    end

  endtask: get_chi_txn
<%}%>

  virtual function int size();
    return m_txn.size();
  endfunction: size

endclass: chi_tx_dat_chnl_cb
