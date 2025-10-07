
//
// uvm sequence
//
class chi_txn_seq #(type T = chi_base_seq_item) extends uvm_sequence #(T);

  `uvm_object_param_utils(chi_txn_seq #(T))

  //Fields
  T m_req[$];
  T rsp;
  

 //Interface Methods
 extern function new(string name = "chi_txn_seq");
 extern task body();
 extern function void push_back(T req);
endclass: chi_txn_seq

//Constructor
function chi_txn_seq::new(string name = "chi_txn_seq");
  super.new(name);
endfunction: new

//push back sequence items
function void chi_txn_seq::push_back(T req);
  m_req.push_back(req);
endfunction: push_back

task chi_txn_seq::body();

  foreach (m_req[i]) begin
    start_item(m_req[i]);
    finish_item(m_req[i]);
    get_response(rsp);
  end

endtask: body
