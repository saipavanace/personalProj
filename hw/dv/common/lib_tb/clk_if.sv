interface clk_if;
   
    bit clk; 
`ifndef VCS    
    bit reset_n = 1;
`else    
    logic reset_n;
`endif    
    bit retention_reset_n = 1;
    bit test_en;
    bit clk_en;
    bit edge_en;
    bit pre_edge_en;

endinterface // clk_if
