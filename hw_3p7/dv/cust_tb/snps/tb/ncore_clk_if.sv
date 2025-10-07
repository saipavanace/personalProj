interface ncore_clk_if;
   
    bit clk; 
    bit reset_n ;
    bit retention_reset_n ;
    bit test_en;
    bit clk_en;
    bit edge_en;
    bit pre_edge_en;

endinterface: ncore_clk_if
