module clk_rst_gen(clk_fr, clk_tb, rst);

output reg clk_fr;
output reg clk_tb;
output reg rst;

parameter RST_CYCLES = 10;
parameter CLK_PERIOD = <%=obj.Clocks[0].params.period%>ps; 
parameter DUTY_CYCLE = 50; //60% duty cycle 
parameter TCLK_HI = (CLK_PERIOD*DUTY_CYCLE/100); 
parameter TCLK_LO = (CLK_PERIOD-TCLK_HI); 
 
wire clk_int;

// assign clk_tb = rst & clk_fr;
assign clk_tb = clk_fr;

initial begin 
 clk_fr = 0; 
 rst = 0;
end

always begin 
  #(TCLK_LO*1ps); 
  clk_fr = 1'b1; 
  #(TCLK_HI*1ps); 
  clk_fr = 1'b0; 
end 

initial begin
// TODO: FIXME: Uncomment below
//  rst <= 1'bx;
//  #1; 
  rst <= 1'b0;
  repeat(RST_CYCLES) @(negedge clk_fr);
  rst <= 1'b1;
end

endmodule
