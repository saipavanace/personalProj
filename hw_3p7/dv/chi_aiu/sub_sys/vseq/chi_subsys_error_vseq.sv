class chi_subsys_error_vseq extends chi_subsys_base_vseq;
	`uvm_object_utils(chi_subsys_error_vseq)

        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
              chi_subsys_error_seq m_error_seq<%=idx%>;
        <%}%>
              protected bit to_execute_body_method_of_chi_subsys_random_vseq=1; // Knob for extended sequence to decide whether body method of base sequence to be run or not. 

		function new(string name = "chi_subsys_error_vseq");
		super.new(name);
       		 <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
            		m_error_seq<%=idx%> = chi_subsys_error_seq::type_id::create("m_error_seq<%=idx%>");
        	 <%}%>
		endfunction

 		virtual	task body();
        		`uvm_info("VSEQ", "Starting chi_subsys_error_vseq", UVM_LOW);
			super.body();
       			 if(to_execute_body_method_of_chi_subsys_random_vseq) begin
       		           fork
            	         	<%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                		   begin
                   		     repeat(chi_num_trans) begin
                       		      m_error_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                    		      end
               			   end
            		        <%}%>
      		           join
                         end
                         `uvm_info("VSEQ", "Finished chi_subsys_error_vseq", UVM_LOW);
		endtask
endclass


