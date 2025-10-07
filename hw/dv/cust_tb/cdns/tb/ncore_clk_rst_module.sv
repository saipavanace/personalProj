module clk_rst_gen(clk_fr, clk_tb, rst);

output reg clk_fr;
output reg clk_tb;
output reg rst;

parameter RST_CYCLES = 5;

parameter CLK_PERIOD = 625 ; 

parameter DUTY_CYCLE = 50; //50% duty cycle 
parameter TCLK_HI = (CLK_PERIOD*DUTY_CYCLE/100); 
parameter TCLK_LO = (CLK_PERIOD-TCLK_HI); 
 
wire clk_int;

assign clk_tb = clk_fr;

initial begin 
 clk_fr = 0; 
 rst = 0;
end

always begin 
  #TCLK_LO; 
  clk_fr = 1'b1; 
  #TCLK_HI; 
  clk_fr = 1'b0; 
end 

initial begin
  rst <= 1'b0;
  #1; 
  rst <= 1'b0;
  repeat(RST_CYCLES) @(posedge clk_fr);
  rst <= 1'b1;
end

endmodule
