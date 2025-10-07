`ifdef PSEUDO_SYS_TB
interface reset_if(input clk);
`else
interface <%=obj.BlockId%>_reset_if(input clk);
`endif
   
   int RESET_CNT_MAX = 10000;
   int HOLD_CNT_MAX = 200;
   
   bit rst_n;
   bit m_inject_rst = 0;
   longint reset_cnt;
   bit 	   force_values = 1;
   bit [31:0] 	   s_DIRUSFER_SfEn, s_DIRUCASER_CaSnpEn_0, s_DIRUMRHER_MrHntEn, s_DIRUCASER_CaSnpEn_3;
   bit [31:0] 	   s_DIRUCASER_CaSnpEn_1, s_DIRUCASER_CaSnpEn_2;
   
   clocking rst_n_cbo @(posedge clk);
      output rst_n;
   endclocking // cbo
   clocking rst_n_cbi @(posedge clk);
      input rst_n;
   endclocking // cbo

   modport force_signals (output s_DIRUSFER_SfEn, output s_DIRUCASER_CaSnpEn_0, output s_DIRUMRHER_MrHntEn, output s_DIRUCASER_CaSnpEn_3);
   
   task automatic collect_reset_packet();
      	 @(negedge rst_n_cbi.rst_n or posedge rst_n_cbi.rst_n);
         if(rst_n_cbi.rst_n)
	   $display($sformatf("@\t%t\tRESET DEACTIVATED",$time));
	 else
	   $display($sformatf("@\t%t\tRESET TRIGGERED",$time));
   endtask // collect_reset_packet
   <% var sf_set_bits = 0;
      var caiu_set_bits_0_l = 0;
      var caiu_set_bits_0_u = 0;
      var caiu_set_bits_1_l = 0;
      var caiu_set_bits_1_u = 0;
      var baiu_set_bits = 0;   
      var hnt_set_bits = 0;
      var hnt_set_bits_index = 0;
      var sf_set_bits_index = 0;
      var caiu_set_bits_index_0 = 0;
      var caiu_set_bits_index_1 = 0;
      var baiu_set_bits_index = 0;   
      obj.SnoopFilterInfo.forEach( function(snoop) {
              sf_set_bits = (sf_set_bits << 1) | 1;
              sf_set_bits_index++;
          }
      );
      obj.DmiInfo.forEach(function(bundle) {
              if(!bundle.interleavedAgent) {
                  hnt_set_bits = (hnt_set_bits << 1) | 1;
                  hnt_set_bits_index++;					      
              }
      });
      obj.AiuInfo.forEach( function(agent) {
              if (caiu_set_bits_index_0 < 32) {
                  if (caiu_set_bits_index_0 < 16) { 
                      caiu_set_bits_0_l = (caiu_set_bits_0_l << 1) | 1;
                  }
                  else {
                      caiu_set_bits_0_u = (caiu_set_bits_0_u << 1) | 1;
                  }
                  caiu_set_bits_index_0++;					 
              }
              else { 
                  if (caiu_set_bits_index_1 < 16) { 
                      caiu_set_bits_1_l = (caiu_set_bits_1_l << 1) | 1;
                  }
                  else {
                      caiu_set_bits_1_u = (caiu_set_bits_1_u << 1) | 1;
                  }
                  caiu_set_bits_index_1++;					 
              }
          }
      );
   %>
   
   task automatic force_reset_values();
    <% if (sf_set_bits_index > 0) { %>
	release s_DIRUSFER_SfEn[<%=sf_set_bits_index - 1%>:0];
    <% } %>
    release s_DIRUCASER_CaSnpEn_0;
    <% if (caiu_set_bits_index_1 > 0) { %>
        release s_DIRUCASER_CaSnpEn_1;
    <% } %>
	release s_DIRUMRHER_MrHntEn[<%=hnt_set_bits_index - 1%>:0];
   endtask // force_reset_values

   task automatic release_reset_values();
   
       <% if (sf_set_bits_index > 0) { %>
       force s_DIRUSFER_SfEn[<%=sf_set_bits_index - 1%>:0] = <%=sf_set_bits_index%>'d<%=sf_set_bits%>;
       <% } %>
       <% if(obj.AiuInfo.length > 0) { %>
           <% if(obj.AiuInfo.length == 1) { %>
               force s_DIRUCASER_CaSnpEn_0[0] = '1;
           <% } else { %>				      
               <% if (caiu_set_bits_index_0 < 16) { %> 
                   force s_DIRUCASER_CaSnpEn_0[<%=caiu_set_bits_index_0 - 1%>:0] = <%=caiu_set_bits_index_0%>'d<%=caiu_set_bits_0_l%>;
               <% } else { %>
                   force s_DIRUCASER_CaSnpEn_0[<%=caiu_set_bits_index_0 - 1%>:0] = {<%=caiu_set_bits_index_0-16%>'d<%=caiu_set_bits_0_u%>, 16'd<%=caiu_set_bits_0_l%>};
               <% } %>
               <% if (caiu_set_bits_index_1 > 0) { %>
                   <% if (caiu_set_bits_index_1 < 16) { %> 
                       force s_DIRUCASER_CaSnpEn_1[<%=caiu_set_bits_index_1 - 1%>:0] = <%=caiu_set_bits_index_1%>'d<%=caiu_set_bits_1_l%>;
                   <% } else { %>
                       force s_DIRUCASER_CaSnpEn_1[<%=caiu_set_bits_index_1 - 1%>:0] = {<%=caiu_set_bits_index_1-16%>'d<%=caiu_set_bits_1_u%>, 16'd<%=caiu_set_bits_1_l%>};
                   <% } %>
               <% } %>
           <% } %>
       <% } %>
 
       <% if (hnt_set_bits_index > 0) { %>
	force s_DIRUMRHER_MrHntEn[<%=hnt_set_bits_index - 1%>:0] = <%=hnt_set_bits_index%>'d<%=hnt_set_bits%>;
       <% } %>
   endtask // force_reset_values
   
   //INITIAL BLOCK TO COUNT DELAYS
   initial begin
      reset_cnt = 0;
      rst_n = 1;
      forever begin
//	 @(posedge clk);
	 #5ns;
	 if(m_inject_rst == 1) begin
	    if(reset_cnt < RESET_CNT_MAX + HOLD_CNT_MAX) 
	      reset_cnt = reset_cnt + 1;
	    else
	      reset_cnt = 0;
	    if (reset_cnt < HOLD_CNT_MAX)
	      rst_n = 0;
	    else
	      rst_n = 1;
	 end // if (m_inject_rst == 1)
	 else begin
	    reset_cnt = 0;
	    rst_n = 1;
	 end // else: !if(m_inject_rst == 1)
      end // forever begin
   end // initial begin
      
endinterface // reset_if
