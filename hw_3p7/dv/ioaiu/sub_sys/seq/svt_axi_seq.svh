//=====================================================================================================================================
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_seq
/* 
 *  This sequence generates parallel read and write master transactions.
 */
//====================================================================================================================================

class svt_axi_seq extends svt_axi_master_base_sequence;
  `svt_xvm_object_utils(svt_axi_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  rand int unsigned sequence_length = 10;
  bit [`SVT_AXI_MAX_ADDR_WIDTH-7:0] user_cacheline_coh_addrq[$];
  io_subsys_axi_master_transaction write_txn[],read_txn[]; 
  bit reduce_addr_area;
  int use_user_addrq;
  bit [<%=obj.AiuInfo[0].wAddr%>-1:0] start_addr,end_addr;
 int wrnosnp_wt ;
  int rdnosnp_wt;
  int wrunq_wt ;
  int rdonce_wt;
  bit wr_coh_txn,wr_non_coh_txn,rd_coh_txn,rd_non_coh_txn;
  int num_rds ;
  int core_id = -1;
  int funitid;
  string nativeif;
    int num_wrs ; 
  function new(string name = "svt_axi_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
        `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
   write_txn = new[num_wrs];
    read_txn  = new[num_rds];
    
    //`uvm_info(get_name(), $psprintf("coh_addrq:%0p", user_cacheline_coh_addrq), UVM_LOW)
    fork
      forever begin
        get_response(rsp);
      end
    join_none
    
    fork
         begin
               for (int i = 0;i < num_wrs; i++) begin
                   gen_addr(1); 
                   `svt_xvm_do_with(write_txn[i],{ 
                                                   xact_type == svt_axi_transaction::WRITE;
                                                   if (reduce_addr_area) {
                                                      if (use_user_addrq) {
                                                          addr[`SVT_AXI_MAX_ADDR_WIDTH-1:6] inside {user_cacheline_coh_addrq};
                                                                          }
                                                      if (use_user_addrq==0) {
                                                          addr inside {[start_addr:end_addr]};
                                                        }

                                                                         } 
                                                    else{
                                                         wr_coh_txn -> write_txn[i].local_axi4_addr_region_pick_ctl ==1;
                                                         wr_non_coh_txn ->write_txn[i].local_axi4_addr_region_pick_ctl ==0;
                                                      }
                                                   })
               end
         end

	 begin
	      for (int i = 0;i < num_rds; i++) begin
                   gen_addr(0);
                   `svt_xvm_do_with(read_txn[i],{
                                                  xact_type == svt_axi_transaction::READ;
          
                                                  if (reduce_addr_area) {
                                                    if (use_user_addrq) {
                                                      addr[`SVT_AXI_MAX_ADDR_WIDTH-1:6] inside {user_cacheline_coh_addrq};
                                                    }
                                                     if (use_user_addrq==0) {
                                                          addr inside {[start_addr:end_addr]};
                                                        }
                                                  }
                                                  else{ 
                                                    rd_coh_txn -> read_txn[i].local_axi4_addr_region_pick_ctl ==1;
                                                    rd_non_coh_txn ->read_txn[i].local_axi4_addr_region_pick_ctl ==0; 
                                                  }

                                                 })
                                                
	    end
	 end

    join
        
    fork
      begin
        for (int i = 0;i < num_wrs;i++) begin 
          write_txn[i].wait_for_transaction_end();
        end  
      end  
      begin
        for (int i = 0;i <num_rds;i++) begin 
          read_txn[i].wait_for_transaction_end();
        end  
      end  
    join

    `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)
  endtask:body
  function void gen_addr(bit wr);
    if(wr)begin
       randcase
            wrnosnp_wt :begin
                           wr_coh_txn=0;
                           wr_non_coh_txn=1;
                        end 
            wrunq_wt  :begin
                           wr_coh_txn=1;
                           wr_non_coh_txn=0;
                        end  
       endcase
    end
    else begin
        randcase

         rdnosnp_wt :begin
                        rd_coh_txn=0;
                        rd_non_coh_txn=1;
                     end
          rdonce_wt: begin
                        rd_coh_txn=1;
                        rd_non_coh_txn=0;
                     end
        endcase

    end
  endfunction

endclass:svt_axi_seq
