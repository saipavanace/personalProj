
//
//Logic to randomly generate primary and secondary selection bits
//

class pri_sel_bits;
  int n_prib;
  int region_width;
  
  rand int pri_bits[$];
  
  constraint c1 {
    foreach (pri_bits[i]) {
      pri_bits[i] inside {[6:region_width-1]};
      foreach  (pri_bits[j])
        (i != j) -> pri_bits[i] != pri_bits[j];
    }
      pri_bits.size() == n_prib;
  }
  
endclass: pri_sel_bits

class sec_sel_bits;
  int priq[$];
  int region_width;
  int n_secb;
  
  rand int sec_bits[$];
  
  constraint c1 {
    foreach (sec_bits[i]) {
      sec_bits[i] inside {[6:region_width-1]};
      !(sec_bits[i] inside {priq});
      foreach (sec_bits[j])
        (i != j) -> sec_bits[i] != sec_bits[j];
    }
      sec_bits.size() inside {[0:n_secb]};
  }
  
endclass: sec_sel_bits

class select_bits_list;
  
  int pri_bits[];
  int sec_bits[][$];
  
  pri_sel_bits m_pri;
  sec_sel_bits m_sec_per_pri;
  
  function void post_randomize();
    `ASSERT(m_pri.randomize());
    
    foreach (m_pri.pri_bits[i]) begin
      pri_bits[i] = m_pri.pri_bits[i];
      m_sec_per_pri.priq.push_back(pri_bits[i]);
    end
    
    foreach (pri_bits[i]) begin
      `ASSERT(m_sec_per_pri.randomize());
      while (m_sec_per_pri.sec_bits.size()) begin
        sec_bits[i].push_back(m_sec_per_pri.sec_bits.pop_front());
      end
    end
    
  endfunction: post_randomize
  
  function void print();
    string s;
    $sformat(s, "%s pri_bits: ", s);
    foreach (pri_bits[i])
      $sformat(s, "%s %0d", s, pri_bits[i]);
      
    foreach (sec_bits[i]) begin
      $sformat(s, "%s\n sec_bits[%0d]", s, i);
      foreach (sec_bits[i,j])
        $sformat(s, "%s %0d", s, sec_bits[i][j]);
    end
    $display(s);
  endfunction: print
  
  //TODO: FIXME Secondary bits not tied
  function new(int nprib, int wregion, int nsecb = 4);
    m_pri = new();
    m_sec_per_pri = new();
    
    m_pri.n_prib  = nprib;
    m_pri.region_width = wregion;
    m_sec_per_pri.n_secb = nsecb;
    m_sec_per_pri.region_width = wregion;
    
    pri_bits = new[nprib];
    sec_bits = new[nprib];
    
  endfunction: new
  
endclass: select_bits_list

