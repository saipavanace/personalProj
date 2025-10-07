class chi_subsys_snp_vseq extends chi_subsys_base_vseq;
	`uvm_object_utils(chi_subsys_snp_vseq)

        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
              chi_subsys_snp_seq m_snp_seq<%=idx%>;
        <%}%>

   		 bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;
   		 bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr1;


		function new(string name = "chi_subsys_snp_vseq");
		super.new(name);
       		 <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            		m_snp_seq<%=idx%> = chi_subsys_snp_seq::type_id::create("m_snp_seq<%=idx%>");
        	 <%}%>
		endfunction

 		virtual	task body();
        		`uvm_info("VSEQ", "Starting chi_subsys_snp_test", UVM_LOW);
			super.body();
       			 addr = m_addr_mgr.gen_coh_addr(0, 1);
       		           fork
            	         	<%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                		   begin
                   		     repeat(chi_num_trans) begin
            			         addr[3:0] = $urandom_range(15,1);
              				 addr1 =addr;
                        		  m_snp_seq<%=idx%>.directed_addr_mailbox.put(addr1);
                       		         m_snp_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    		      end
               			   end
            		        <%}%>
      		           join
                         `uvm_info("VSEQ", "Finished chi_subsys_snp_test", UVM_LOW);
		endtask
endclass






